class ScheduleTemplate < ActiveRecord::Base
  belongs_to :department
  has_many :schedule_shifts, :dependent => :destroy

  def check_day(day)
    total_normal = 0
    @users = User.find_all_by_department_id_and_active self.department_id, 1
    @users.each do |user|
      total_normal += user.identifier * user.norm
    end
    total_fact = 0
    ap day
    shifts = ScheduleShift.includes(:schedule_cells).find_all_by_schedule_template_id self.id
    shifts.each do |shift|
      hours = shift.end - shift.start
      cells = shift.schedule_cells.find_all{|k| k.day == day}
      unless cells.nil?
        cells.each do |cell|
          if shift.number == 10
            ap cell.user_id
            user = @users.find{|k| k.identifier == cell.user_id.to_i}
            total_fact += cell.user_id * user.norm unless cell.user_id.nil? or user.nil?
          else
            total_fact += cell.user_id * hours unless cell.user_id.nil?
          end
        end
      end
    end
    total_normal <=> total_fact
  end

  def check_day_detailed(day)
    missed = []
    extra = []
    @users = User.find_all_by_department_id_and_active self.department_id, 1
    @shifts = ScheduleShift.includes(:schedule_cells).find_all_by_schedule_template_id self.id
    @users.each do |user|
      total_fact = 0
      @shifts.each do |shift|
        hours = shift.end - shift.start
        cells = shift.schedule_cells.find_all{|k| k.day == day.to_i}
        unless cells.nil?
          cells.each do |cell|
            if shift.number == 10
              total_fact += user.norm if cell.user_id == user.identifier
            else
              total_fact += hours if cell.user_id == user.identifier
            end
          end
        end
      end
      missed << user.identifier if total_fact < user.norm
      extra << user.identifier if total_fact > user.norm
    end
    [missed.sort, extra.sort]
  end
end
