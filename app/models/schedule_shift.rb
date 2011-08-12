class ScheduleShift < ActiveRecord::Base
  belongs_to :schedule_template
  has_many :schedule_cells
  validates_numericality_of :number, :lines, :end, :greater_than => 0
  validates_numericality_of :start
end
