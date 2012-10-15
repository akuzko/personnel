class Api::LeaderShiftsController < Api::BaseController
  before_filter :check_params
  def index
    @user = User.find_by_id params[:user_id]
    error!('User not found', 404) and return unless @user
    conditions = []
    conditions.push("schedule_shift_id IS NOT NULL")
    conditions.push("number IN (1,2,3,4,5)")
    conditions.push("`shifts`.shiftdate >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("`shifts`.shiftdate <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?
    date = ""
    date_hash = []
    @shifts = @user.shifts.includes(schedule_shift: :schedule_cells).where(conditions.join(' and ')).group(:shiftdate, :number).order(:shiftdate, :number)
    shifts_hash = @shifts.inject([]) do |res, shift|
      if shift.schedule_shift.schedule_cells.find{|k| k.day == shift.shiftdate.day and k.responsible == 1 and k.user_id == @user.identifier}
        if date == shift.shiftdate.to_formatted_s(:db)
          date_hash << shift.number
        else
          res << {date => {shifts: date_hash}} unless date_hash.blank?
          date_hash = [shift.number]
          date = shift.shiftdate.to_formatted_s(:db)
        end

        if shift == @shifts.last
          res << {date => {shifts: date_hash}} unless date_hash.blank?
        end
      end
      res
    end
    respond_to do |format|
      format.json { render json: shifts_hash }
    end
  end

  private

  def check_params
    %w(date_from date_to user_id).each do |param|
      error!("Missing required parameter: #{param}", 404) and return unless params[param.to_sym]
    end
  end
end