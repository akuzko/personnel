class ScheduleShift < ActiveRecord::Base
  belongs_to :schedule_template
  has_many :schedule_cells
end
