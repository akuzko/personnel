class Address < ActiveRecord::Base
  belongs_to :user

  def full
    attributes = %w(street build porch nos)
    separators = [', ', ' || ', ' / ']
    return nil if attributes.any?{ |a| self[a].nil? || self[a] == '' }
    attributes.map{ |a| self[a] }.zip(separators).flatten.compact.join
  end

end
