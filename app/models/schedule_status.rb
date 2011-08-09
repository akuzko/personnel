class ScheduleStatus < ActiveRecord::Base
  validates_presence_of :name, :color
  validates_uniqueness_of :name

end
