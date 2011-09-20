class Norm < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :weekend, :workdays
  validates_numericality_of :weekend, :workdays

  def self.norms_defaults(y, m)
    days = (Date.new(y,12,31).to_date<<(12-m)).day
    holidays = 0
    days.times do |d|
      holidays += 1 if [0,6].include?(Time.local(y, m, d+1).wday)
    end
    new({:weekend => holidays, :workdays => days - holidays})
  end

  def self.set_norms(u, template, default_norm)
    @shift = template.schedule_shifts.where(:number => 10).first
    vacations = @shift.schedule_cells.where(:additional_attributes => ScheduleStatus.find_by_name("Vacation"), :user_id => u.identifier).count
    days = (Date.new(template.year,12,31).to_date<<(12-template.month)).day
    @norm = Norm.find_or_create_by_user_id_and_year_and_month(u.id, template.year, template.month)

    if vacations
      weekend = (1.0 * (days - vacations) / days * default_norm[:weekend].to_i).round
      workdays = days - vacations - weekend
      @norm.weekend = weekend + vacations
      @norm.workdays = workdays
      @norm.save
    else
      @norm.update_attributes default_norm
    end
    @norm
  end
end