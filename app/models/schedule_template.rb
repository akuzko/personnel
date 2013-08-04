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
    shifts = ScheduleShift.includes(:schedule_cells).find_all_by_schedule_template_id self.id
    shifts.each do |shift|
      hours = shift.end - shift.start
      hours += 24 if hours < 0
      cells = shift.schedule_cells.find_all{|k| k.day == day}
      unless cells.nil?
        cells.each do |cell|
          if shift.number == 10
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
        hours += 24 if hours < 0
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


  def self.vacations(params, admin_id)
    #SELECT u.email, c.additional_attributes, count(c.id) FROM `schedule_templates` t
    #INNER JOIN schedule_shifts s ON s.schedule_template_id = t.id
    #INNER JOIN schedule_cells c ON c.schedule_shift_id = s.id
    #INNER JOIN users u ON c.user_id = u.identifier AND u.active = 1
    #WHERE c.additional_attributes IN (3, 5)
    #AND STR_TO_DATE(CONCAT_WS('-', t.year, t.month, c.day), '%Y-%m-%d') BETWEEN '2012-04-01' AND '2013-05-16'
    #GROUP BY u.email, c.additional_attributes
    #ORDER BY u.email, c.additional_attributes
    model_query = select('CONCAT(profiles.last_name," ",profiles.first_name) as username, schedule_templates.year, schedule_templates.month, c.additional_attributes, count(c.id) as total')
    model_query = model_query.joins('INNER JOIN schedule_shifts s ON s.schedule_template_id = schedule_templates.id')
    model_query = model_query.joins('INNER JOIN schedule_cells c ON c.schedule_shift_id = s.id')
    model_query = model_query.joins('INNER JOIN users u ON c.user_id = u.identifier AND u.active = 1')
    model_query = model_query.joins('INNER JOIN profiles ON profiles.user_id = u.id')
    model_query = model_query.where("u.id IN (?)", params[:user_ids].join(',') ) unless params[:user_ids].blank?
    model_query = model_query.where("u.department_id = ?", params[:department_id]) unless params[:department_id].blank?
    model_query = model_query.where("c.additional_attributes IN (4, 5, 6)")

    if admin_id != 0
      admin = Admin.find_by_id(admin_id)
      model_query = model_query.where("`u`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    end

    model_query = model_query.where("STR_TO_DATE(CONCAT_WS('-', schedule_templates.year, schedule_templates.month, c.day), '%Y-%m-%d') >= '" + params[:date_from].to_s + "'") unless params[:date_from].blank?
    model_query = model_query.where("STR_TO_DATE(CONCAT_WS('-', schedule_templates.year, schedule_templates.month, c.day), '%Y-%m-%d') <= '" + params[:date_to].to_s + "'") unless params[:date_to].blank?
    model_query = model_query.group('username, schedule_templates.year, schedule_templates.month, c.additional_attributes')
    model_query = model_query.order('username, schedule_templates.year, schedule_templates.month, c.additional_attributes')
    model_query.all
  end
end
