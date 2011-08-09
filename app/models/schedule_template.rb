class ScheduleTemplate < ActiveRecord::Base
  belongs_to :department
  has_many :schedule_shifts
end
