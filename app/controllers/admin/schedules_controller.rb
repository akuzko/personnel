class Admin::SchedulesController < ApplicationController
  layout 'admin'
  def show
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = 6 unless params[:department_id]
    @template = ScheduleTemplate.find_or_create_by_department_id_and_year_and_month(params[:department_id], params[:date].year, params[:date].month)
    params[:visible] = @template.visible?
    @users = User.order(:identifier).find_all_by_department_id params[:department_id]
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_by_name('shift_leader').color
  end
end
