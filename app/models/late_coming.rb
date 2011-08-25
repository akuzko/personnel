class LateComing < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift
  validates_presence_of :description, :user_id, :shift_id
end
