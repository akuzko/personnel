class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_shift_started, :except => [:start_shift, :create_shift, :available_shift_numbers]
  layout 'user'

  def index
    @shift = Shift.find session[:shift_id]
    if @shift.is_late && @shift.late_coming.nil?
      redirect_to new_late_coming_events_path
      return
    end
    #Check if the current shift is over
    if @shift.is_over
      @template = ScheduleTemplate.find_by_department_id_and_year_and_month(current_user.department_id, Date.current.year, Date.current.month)
      @shift_next = @template.schedule_shifts.where('number < 10 AND number > ?', @shift.number).order(:number).first unless @template.nil?
      if @shift_next && @shift_next.schedule_cells.find_all_by_user_id_and_day(current_user.identifier, Date.current.day).count > 0
        #End current shift
        @event = User.find(current_user.id).events.order(:eventtime).last
        @shift.end_event = Event.logout(current_user.id, [@shift.shiftdate + @shift.schedule_shift.end.hour, @event.eventtime + 1.minute].max, request.remote_ip)
        @shift.save
        #Start new shift
        @shift = Shift.find_or_create_by_shiftdate_and_number_and_user_id(Date.current, @shift_next.number, current_user.id)
        session[:shift_id] = @shift.id
        #Check if the next shift for the user is not started
        if @shift.start_event.nil?
          #add login event
          @shift.start_event = Event.login(current_user.id, @shift.shiftdate + @shift.schedule_shift.start.hour, request.remote_ip)
          @shift.save
        end
        flash[:notice] ||= ''
        redirect_to events_path, :notice => (flash[:notice] + "<br/>Your shift was automatically changed to #{@shift.number} (#{@shift.shiftdate} #{@shift.schedule_shift.start}:00 - #{@shift.schedule_shift.end}:00)").html_safe
      end
    end
    params[:sort_by] ||= :eventtime
    params[:sort_order] ||= 'DESC'
    @events = current_user.events.where('events.id > ?', @shift.start_event).joins('INNER JOIN `categories` ON `events`.`category_id` = `categories`.`id`').where('`categories`.`displayed` =1').paginate :page => params[:page], :per_page => 30, :order => "#{params[:sort_by]} #{params[:sort_order]}"
  end

  def show

  end

  def new
    @event = Event.new
    render :layout => false
  end

  def edit
    @event = Event.find(params[:id])
    render :layout => false
  end

  def create
    @event = Event.new(params[:event])
    @event.user_id = current_user.id
    @event.eventtime = DateTime.current
    @event.ip_address = Event.ip2int(request.remote_ip)

    if @event.save
      render(:update) do |page|
        page["#overlay"].dialog("close")
        flash[:notice] = t("personnel.event.Record has been added", :default => "Record has been added")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @event.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#event_flash'].parents(0).show
        page['#event_flash'].html message
      end
    end

  end

  def update
    @event = Event.find(params[:id])
    @event.user_id = current_user.id
    @event.ip_address = Event.ip2int(request.remote_ip)

    if @event.update_attributes(params[:event])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @event.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#event_flash'].parents(0).show
        page['#event_flash'].html message
      end
    end

  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml { head :ok }
    end
  end

  def check_shift_started
    redirect_to start_shift_events_path unless session[:shift_id]
  end

  def start_shift
    if !current_user.has_identifier?
      flash[:error] = "You dont have permissions to view this page"
      redirect_to user_path
    end
    @shift = Shift.new
    @shift.shiftdate = Date.current + 1.day if DateTime.current.hour == 23
  end

  def create_shift
    shiftdate = (params[:shift]["shiftdate(1i)"].to_s+"-"+params[:shift]["shiftdate(2i)"].to_s+"-"+params[:shift]["shiftdate(3i)"].to_s).to_date
    @shift = Shift.find_or_create_by_shiftdate_and_number_and_user_id(shiftdate, params[:shift][:number], current_user.id)
    if @shift
      if @shift.start_event.nil?
        #add login event
        @shift.start_event = Event.login(current_user.id, DateTime.current, request.remote_ip)
        @shift.save
      end
      session[:shift_id] = @shift.id
      redirect_to events_path
    else
      flash[:error] = @shift.errors
      redirect_to start_shift_events_path
    end

  end

  def end_shift
    @shift = Shift.find(session[:shift_id])
    #add logout event
    @shift.end_event = Event.logout(current_user.id, DateTime.current, request.remote_ip)
    @shift.save
    session.delete :shift_id
    redirect_to events_path
  end

  def available_shift_numbers
    @date = params[:date].to_date
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month(current_user.department_id, @date.year, @date.month)
    @shifts = @template.schedule_shifts.where('number < 10').order(:number) unless @template.nil?

    # user's shifts
    @shift_numbers = []
    @shifts.each do |shift|
      if shift.schedule_cells.find_all_by_user_id_and_day(current_user.identifier, @date.day).count > 0
        @shift_numbers.push ["#{shift.number} (#{shift.start}:00-#{shift.end}:00)", shift.number]
      end
    end

    # selected shift number
    shift = @shifts.where('start<=? and end>?', (Time.now.hour + 2), Time.now.hour).last
    @selected_number = shift.number unless shift.nil?
    render :layout => false
  end

  def new_late_coming
    @shift = Shift.find session[:shift_id]
    if !@shift.is_late || !@shift.late_coming.nil?
      redirect_to events_path
      return
    end
    @late_coming = LateComing.new
    @late_coming.shift_id = session[:shift_id]
    @late_coming.user_id = current_user.id
    @late_coming.late_minutes = (@shift.starttime - (@shift.shiftdate + @shift.schedule_shift.start.hour))/ 1.minutes

  end

  def create_late_coming
    @shift = Shift.find session[:shift_id]
    if !@shift.is_late || !@shift.late_coming.nil?
      redirect_to events_path
      return
    end
    @late_coming = LateComing.new
    @late_coming.shift_id = session[:shift_id]
    @late_coming.user_id = current_user.id
    @late_coming.late_minutes = (@shift.starttime - (@shift.shiftdate + @shift.schedule_shift.start.hour))/ 1.minutes
    @late_coming.description = params[:late_coming][:description]
    if @late_coming.save
      redirect_to events_path
    else
      flash[:error] = @late_coming.errors.full_messages
      redirect_to :back
    end
  end

end
