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

end