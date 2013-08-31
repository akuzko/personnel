# encoding: UTF-8
require 'net/http'
class Address < ActiveRecord::Base
  belongs_to :user
  has_many :logs, :as => :subject
  validates_presence_of :street, :build, :porch, :nos, :room
  validates_numericality_of :porch, :nos

  def full
    attributes = %w(street build porch nos)
    separators = [', ', ' || ', ' / ']
    return nil if attributes.any?{ |a| self[a].nil? || self[a] == '' }
    attributes.map{ |a| self[a] }.zip(separators).flatten.compact.join
  end

  def full_admin
    attributes = %w(street build porch nos room)
    separators = [', ', ' || ', ' / ', 'app.']
    return nil if attributes.any?{ |a| self[a].nil? || self[a] == '' }
    attributes.map{ |a| self[a] }.zip(separators).flatten.compact.join
  end

  def get_map
    # make Google API reverse geo call
    address_string = URI.escape("Харьков,+#{self.street},+#{self.build}")
    url = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{address_string}&sensor=false")

    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    json = JSON.parse(res.body)

    if json["status"] == 'OK'
      # avoid updating a timestamp
      Address.record_timestamps= false
      self.assign_attributes(
          lat: json["results"][0]["geometry"]["location"]["lat"],
          lng: json["results"][0]["geometry"]["location"]["lng"],
      )
      self.save(validate: false)
      Address.record_timestamps= true
    else
      puts json["status"]
    end
  end

end
