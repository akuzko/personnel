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
end
