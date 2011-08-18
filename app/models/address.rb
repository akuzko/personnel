class Address < ActiveRecord::Base
  belongs_to :user
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

end
