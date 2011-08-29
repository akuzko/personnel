class Admin::SchedulesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def show
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = Department.selection_by_admin(current_admin.id).first[1] unless params[:department_id]
    redirect_to admin_users_path unless current_admin.manage_department(params[:department_id].to_i)
    @template = ScheduleTemplate.find_or_create_by_department_id_and_year_and_month(params[:department_id], params[:date].year, params[:date].month)
    if @template.schedule_shifts.empty?
      @previous_template = ScheduleTemplate.where('id < ?', @template.id).order('year DESC, month DESC').limit(1).find_by_department_id(params[:department_id])
      if @previous_template
        @previous_template.schedule_shifts.each do |shift|
          @shift = ScheduleShift.create(:schedule_template_id => @template.id, :lines => shift.lines, :number => shift.number, :start => shift.start, :end => shift.end)
          @shift.save
        end
      end
    end
    params[:visible] = @template.visible?
    @users = User.order(:identifier).find_all_by_department_id_and_active params[:department_id], 1
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_by_name('shift_leader').color
  end

  def show_users
    @template = ScheduleTemplate.find params[:id]
    @users = User.order(:identifier).find_all_by_department_id_and_active @template.department_id, 1
    @admin = true
    render :partial => 'shared/template_users_show', :layout => false, :locals => {:template => @template, :users => @users}
  end
end
