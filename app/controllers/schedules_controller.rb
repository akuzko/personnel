class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  layout 'user'
  def show
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = 6 unless params[:department_id]
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month_and_visible(params[:department_id], params[:date].year, params[:date].month, 1)
    if @template.nil?
      redirect_to new_schedule_path
    else
      @users = User.order(:identifier).find_all_by_department_id_and_active params[:department_id], 1
      @days_in_month = Time.days_in_month(@template.month, @template.year)
      @shift_leader_color = ScheduleStatus.find_by_name('shift_leader').color
      @statuses = ScheduleStatus.order(:name).all
    end
  end

  def new

  end

end