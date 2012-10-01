class Api::UsersController < Api::BaseController
  before_filter :check_params, :only => [:rate, :feedbacks, :shifts]
  def index
    error!('Missing required parameter: department_id', 404) and return unless params[:department_id]
    @users = User.with_data.active.where(department_id: params[:department_id]).inject([]) do |res, i|
      res << {id: i.id, identifier: i.identifier, name: i.full_name, created: i.created_at}
      res
    end
    respond_to do |format|
      format.json { render json: @users }
    end
  end

  def rate
    conditions = []
    conditions.push("`users`.department_id =  %d " % params[:department_id]) unless params[:department_id].blank?
    conditions.push("score_date >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("score_date <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?

    @average = SelfScore.select("avg(score) as avg_score").joins(:user).where(conditions.join(' and ')).first

    respond_to do |format|
      format.json { render json: @average.avg_score }
    end
  end

  def feedbacks
    error!('Not implemented yet', 501)
  end

  def shifts
    conditions = []
    conditions.push("`users`.department_id =  %d " % params[:department_id]) unless params[:department_id].blank?
    conditions.push("shiftdate >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("shiftdate <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?
    @shifts = Shift.select("count(*) as total_employees, number, schedule_shift_id, shiftdate").
        joins(:user).
        includes(:schedule_shift).
        where(conditions.join(' and ')).
        group(:schedule_shift_id, :number, :shiftdate).
        order(:shiftdate, :number)
    date = @shifts.first.shiftdate.to_formatted_s(:db)
    date_hash = {}
    shifts_hash = @shifts.inject([]) do |res,shift|
      # shift_leader
      shift_leader_cell = shift.schedule_shift.schedule_cells.find_by_day_and_responsible(shift.shiftdate.strftime("%d"), 1)
      if shift_leader_cell
        user = User.find_by_identifier(shift_leader_cell.user_id)
        shift_leader = {id: user.id, identifier:user.identifier, name: user.full_name}
      else
        shift_leader = nil
      end
      date_hash.merge!(shift.number => {total_employees: shift.total_employees, shift_leader: shift_leader})
      if date != shift.shiftdate.to_formatted_s(:db) or shift == @shifts.last
        res << {date => date_hash} unless date_hash.blank?
        date_hash = {}
        date = shift.shiftdate.to_formatted_s(:db)
      end
      res
    end
    respond_to do |format|
      format.json { render json: shifts_hash }
    end
  end

  private

  def check_params
    %w(date_from date_to department_id).each do |param|
      error!("Missing required parameter: #{param}", 404) and return unless params[param.to_sym]
    end
  end
end
