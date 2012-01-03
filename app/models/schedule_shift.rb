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

  def update_shift(params)
    new_lines = params[:schedule_shift][:lines].to_i
    current_lines = ScheduleShift.find(params[:id]).lines
    # Delete cells in deleted shift lines
    if new_lines < current_lines
      ScheduleCell.delete_all("`schedule_shift_id` = #{params[:id]} AND `line` > #{new_lines}")
    end
    self.update_attributes(params[:schedule_shift])
  end

end
