class ScheduleCell < ActiveRecord::Base
  belongs_to :schedule_shift

  def date
    Date.parse("#{schedule_shift.schedule_template.year}-#{schedule_shift.schedule_template.month}-#{day}")
  end
end
