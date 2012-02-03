class ShiftsController < ApplicationController
  def close_old
    # Close old shifts, run every hour
    @shifts = Shift.where('shiftdate <= ?', Date.current).where('end_event =0 OR end_event IS NULL').all
    @shifts.each do |shift|
      next_shift = Shift.where('number < 10').where('id > ?', shift.id). order(:id).find_all_by_user_id(shift.user_id).first
      #find last user's event
      if next_shift.nil?
        @event = User.find(shift.user_id).events.order(:eventtime).last
      else
        @event = User.find(shift.user_id).events.where('id < ?', next_shift.start_event).order(:eventtime).last
      end
      ap @event
      if @event
        if (shift.shiftdate + shift.schedule_shift.end.hour < DateTime.current) && @event.eventtime < DateTime.current - 1.hour
          #add logout event
          shift.end_event = Event.logout(shift.user_id, @event.eventtime + 1.minute, request.remote_ip)
          #shift.time_difference = (((@event.eventtime + 1.minute).to_datetime - shift.created_at.to_datetime) * 24 * 60).minutes - 480.minutes
          #close shift
          shift.save
        end
      end
    end
    render :nothing => true
  end

  def check
    #Check shifts for previous day, run at 0:05 every day
    @date = Date.current - 1.day
    @missed_shifts_departments = {}
    @templates = ScheduleTemplate.where('year = ?', @date.year).where('month = ?', @date.month).where('visible = 1').all
    @templates.each do |template|
      missed_shifts = []
      department = Department.find(template.department_id)
      admins = department.admins.map(&:email)
      template.schedule_shifts.each do |shift|
        if shift.number < 10
          shift.schedule_cells.each do |cell|
            if !cell.user_id.nil? && cell.day == @date.day
              user = User.find_by_identifier_and_active(cell.user_id, 1)
              count = Shift.find_all_by_user_id_and_number_and_shiftdate(user.id, shift.number, @date).count
              missed_shifts.push [user.full_name, @date, shift.number, shift.start, shift.end] if count == 0
            end
          end
        end
      end
      if !missed_shifts.empty?
        @missed_shifts_departments[department.name] = {}
        @missed_shifts_departments[department.name][:shifts] = missed_shifts
        @missed_shifts_departments[department.name][:admins] = admins
        if params[:send] && department.id != 2
            message = MissedShift.send_missed_shifts(department.name, missed_shifts, admins)
            message.deliver
        end
      end
    end
  end

  def check_department_for_identifier
    render :text => Department.find(params[:id]).has_identifier
  end
end
