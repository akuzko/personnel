class ShiftLeaderScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift_leader, :class_name => "User", :foreign_key => "shift_leader_id"
  delegate :full_name, :to => :user, :prefix => true
  attr_accessible :score, :comment, :shift_date, :shift_number
  validates_presence_of :score
end
