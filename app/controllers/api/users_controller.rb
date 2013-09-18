class Api::UsersController < Api::BaseController
  before_filter :check_params, :only => [:rate, :rates, :feedbacks, :shifts, :nc_report]
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

  def rates
    conditions = []
    conditions.push("`users`.department_id IN (%s) " % params[:department_id]) unless params[:department_id].blank?
    conditions.push("score_date >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("score_date <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?

    scores = SelfScore.select("score_date, count(*) as count, avg(score) as avg").group(:score_date).joins(:user).where(conditions.join(' and '))

    date_hash = scores.inject({}) do |res, score|
      res[score.score_date] = {
          count: score.count,
          average: score.avg
      }
      res
    end

    respond_to do |format|
      format.json { render json: date_hash }
    end
  end

  def feedbacks
    # Survey Follow-up
    @category = Category.find_by_name('Survey Follow-up')
    error!('Category Survey Follow-up not found', 404) and return unless @category
    conditions = []
    conditions.push("`events`.category_id = %d" % @category.id)
    conditions.push("`users`.department_id =  %d " % params[:department_id]) unless params[:department_id].blank?
    conditions.push("`shifts`.shiftdate >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("`shifts`.shiftdate <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?

    @events = Event.select("count(*) as total_tickets, number, shiftdate").
        joins(:user).
        joins(:shift).
        where(conditions.join(' and ')).
        group("shifts.shiftdate, shifts.number").
        order("shifts.shiftdate, shifts.number")
    date = ""
    date_hash = {}
    shifts_hash = @events.inject([]) do |res,shift|
      if date == shift.shiftdate.to_formatted_s(:db)
        date_hash.merge!(shift.number => shift.total_tickets)
      else
        res << {date => date_hash} unless date_hash.blank?
        date_hash = {shift.number => shift.total_tickets}
        date = shift.shiftdate.to_formatted_s(:db)
      end

      if shift == @events.last
        res << {date => date_hash} unless date_hash.blank?
      end
      res
    end
    respond_to do |format|
      format.json { render json: shifts_hash }
    end
  end

  def shifts
    conditions = []
    conditions.push("number IN (1,2,3,4,5)")
    conditions.push("schedule_shift_id IS NOT NULL")
    conditions.push("`users`.department_id =  %d " % params[:department_id]) unless params[:department_id].blank?
    conditions.push("shiftdate >= '%s'" % Date.parse(params[:date_from]).to_formatted_s(:db)) unless params[:date_from].blank?
    conditions.push("shiftdate <= '%s'" % Date.parse(params[:date_to]).to_formatted_s(:db)) unless params[:date_to].blank?
    @shifts = Shift.select("count(*) as total_employees, number, schedule_shift_id, shiftdate").
        joins(:user).
        includes(schedule_shift: :schedule_cells).
        where(conditions.join(' and ')).
        group(:schedule_shift_id, :number, :shiftdate).
        order(:shiftdate, :number)
    date = ""
    date_hash = {}
    shifts_hash = @shifts.inject([]) do |res,shift|
      # shift_leader
      shift_leader_cell = shift.schedule_shift.schedule_cells.find{|k|k.day == shift.shiftdate.day and k.responsible == 1}
      if shift_leader_cell
        user = User.find_by_identifier_and_active(shift_leader_cell.user_id, true)
        shift_leader = {id: user.id, identifier:user.identifier, name: user.full_name} rescue nil
      else
        shift_leader = nil
      end

      # excluded statuses

      # 13	 Training Supervisor
      # 16	 CS Supervision
      # 18	 KB Responsible
      # 7	   Legal & Abuse
      # 2	   New
      # 11	 On Training

      excluded = shift.schedule_shift.schedule_cells.find_all{|k|k.day == shift.shiftdate.day and
          [13, 16, 18, 7, 2, 11].include?(k.additional_attributes)}.count

      if date == shift.shiftdate.to_formatted_s(:db)
        date_hash.merge!(shift.number => {total_employees: shift.total_employees - excluded, shift_leader: shift_leader})
      else
        res << {date => date_hash} unless date_hash.blank?
        date_hash = {shift.number => {total_employees: shift.total_employees - excluded, shift_leader: shift_leader}}
        date = shift.shiftdate.to_formatted_s(:db)
      end

      if shift == @shifts.last
        res << {date => date_hash} unless date_hash.blank?
      end
      res
    end
    respond_to do |format|
      format.json { render json: shifts_hash }
    end
  end

  def nc_report
    respond_to do |format|
      # NC Account activation
      activation_id = 66
      # NC Failed orders
      failed_orders_id = 110
      # NC Payment reminder call
      payment_reminder_id = 81
      # NC Phone calls
      phone_call_id = 77

      categories = {
          activation_id => 0,
          failed_orders_id => 0,
          payment_reminder_id => 0,
          phone_call_id => 0
      }

      @events = Event.select('category_id, count(*) as total').
          joins(:user).
          where('eventtime >= ?', params[:date_from]).
          where('eventtime <= ?', params[:date_to]).
          where('users.department_id = ?', params[:department_id].to_i).
          where(category_id: categories.keys).
          group(:category_id)

      @shifts = Shift.select('count(*) as total').
          joins(:user).
          where('shiftdate >= ?', params[:date_from]).
          where('shiftdate <= ?', params[:date_to]).
          where('users.department_id = ?', params[:department_id].to_i).
          where('number IN (1,2,3,4,5)').
          where("schedule_shift_id IS NOT NULL").
          group(:schedule_shift_id, :number, :shiftdate)

      shifts_count = @shifts.first.total

      @events.each do |event|
        categories[event.category_id] = event.total
      end

      result = {
        'average activations per shift' => "%.2f" % (categories[activation_id].to_f / shifts_count),
        'average failed orders per shift' => "%.2f" % (categories[failed_orders_id].to_f / shifts_count),
        'average calls per shift' => "%.2f" % ((categories[payment_reminder_id] + categories[phone_call_id]).to_f / shifts_count),
      }
      format.json { render json: result }
    end
  end

  private

  def check_params
    %w(date_from date_to department_id).each do |param|
      error!("Missing required parameter: #{param}", 404) and return unless params[param.to_sym]
    end
  end
end
