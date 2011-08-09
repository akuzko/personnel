class ScheduleCell < ActiveRecord::Base
  belongs_to :schedule_shift
  belongs_to :user
end
