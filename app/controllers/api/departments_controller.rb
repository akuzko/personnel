class Api::DepartmentsController < Api::BaseController

  def index
    @departments = Department.all.inject([]) do |res, i|
      res << {id: i.id, name: i.name}
      res
    end
    respond_to do |format|
      format.json { render json: @departments }
    end
  end

  def show
    error!('Missing required parameter: month', 404) and return unless params[:month]
    error!('Missing required parameter: year', 404) and return unless params[:year]

    template = ScheduleTemplate.find_by_department_id_and_month_and_year(params[:id], params[:month], params[:year])
    error!('Schedule not found', 404) and return unless template
    user_ids, newbies = [], []
    template.schedule_shifts.where("number < 10").each do |shift|
      user_ids = user_ids + shift.schedule_cells.where("additional_attributes != 13 OR additional_attributes IS NULL").map(&:user_id)
      newbies = newbies + shift.schedule_cells.where(additional_attributes: 2).map(&:user_id)
    end
    respond_to do |format|
      format.json { render json: {total: user_ids.uniq.size, newbies: newbies.uniq.size} }
    end
  end
end
