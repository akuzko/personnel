class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  layout 'user'
  def show
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = User.find(current_user.id).department_id unless params[:department_id]
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month_and_visible(params[:department_id], params[:date].year, params[:date].month, 1)
    if @template.nil?
      flash[:error] = "No schedule available at this time"
      redirect_to new_schedule_path
      return
    end
    @users = User.order(:identifier).find_all_by_department_id_and_active params[:department_id], 1
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_by_name('Shift Leader').color
    @statuses = ScheduleStatus.order(:name).all
  end

  def new
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = @user = User.find(current_user.id).department_id unless params[:department_id]
  end

  def edit
    redirect_to user_path unless current_admin.manage_department(params[:department_id].to_i)
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
    params[:visible] = @template.visible
    @users = User.order(:identifier).find_all_by_department_id_and_active params[:department_id], 1
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_or_create_by_name('Shift Leader').color
    @statuses = ScheduleStatus.order(:name).all
  end

end