class ScheduleShift < ActiveRecord::Base
  belongs_to :schedule_template
  has_many :schedule_cells, :dependent => :destroy

  validates_numericality_of :number, :lines, :end, :greater_than => 0
  validates_numericality_of :start
  validates_uniqueness_of :number, :scope => [:schedule_template_id]
  before_validation :update_dayoff_interval

  def update_dayoff_interval
    if self.number == 10
      self.start = 0
      self.end = 8
    end
  end
end
