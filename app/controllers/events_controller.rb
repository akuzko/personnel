class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile
  before_filter :check_shift_started, :except => [:start_shift, :create_shift, :available_shift_numbers, :processed_by_person, :new_self_score, :create_self_score]
  layout 'user'

  def index
    @shift = Shift.find session[:shift_id]
    if @shift.is_late && @shift.late_coming.nil?
      redirect_to new_late_coming_events_path
      return
    end
    #Check if the current shift is over and its today's shift
    if @shift.is_over and @shift.shiftdate == Date.current
      @template = ScheduleTemplate.find_by_department_id_and_year_and_month(current_user.department_id, Date.current.year, Date.current.month)
      @shift_next = @template.schedule_shifts.where('number < 10 AND number > ?', @shift.number).order(:number).first unless @template.nil?
      if @shift_next && @shift_next.schedule_cells.find_all_by_user_id_and_day(current_user.identifier, Date.current.day).count > 0
        #End current shift
        @event = User.find(current_user.id).events.order(:eventtime).last
        #@shift.end_event = Event.logout(current_user.id, [@shift.shiftdate + @shift.schedule_shift.end.hour, @event.eventtime + 1.minute].max, request.remote_ip, @shift.id)
        @shift.end_event = Event.logout(current_user.id, @shift.shiftdate + @shift.schedule_shift.end.hour, request.remote_ip, @shift.id)
        @shift.save
        #Start new shift
        @shift = Shift.find_or_create_by_shiftdate_and_number_and_user_id(Date.current, @shift_next.number, current_user.id)
        session[:shift_id] = @shift.id
        #Check if the next shift for the user is not started
        if @shift.start_event.nil?
          #add login event
          @shift.start_event = Event.login(current_user.id, @shift.shiftdate + @shift.schedule_shift.start.hour, request.remote_ip, @shift.id)
          @shift.save
        end
        flash[:notice] ||= ''
        redirect_to events_path, :notice => (flash[:notice] + "<br/>Your shift was automatically changed to #{@shift.number} (#{@shift.shiftdate} #{@shift.schedule_shift.start}:00 - #{@shift.schedule_shift.end}:00)").html_safe
      end
    end
    if Department.find(current_user.department_id).has_events == false
      @no_events = true
      flash[:notice] = 'No further actions is required by you.'
    end
    params[:sort_by] ||= :eventtime
    params[:sort_order] ||= 'DESC'
    @events = current_user.events.where('events.id > ?', @shift.start_event).joins('INNER JOIN `categories` ON `events`.`category_id` = `categories`.`id`').where('`categories`.`displayed` =1').paginate :page => params[:page], :per_page => 30, :order => "#{params[:sort_by]} #{params[:sort_order]}"

    # self score
    @display_self_score = self_score_available?(@shift, :current)
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
    @event.shift_id = session['shift_id']

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
      redirect_to user_path and return
    end
    shift = current_user.shifts.where("shiftdate <= ?", Date.current).order(:shiftdate).order(:number).last
    redirect_to new_self_score_events_path and return if self_score_available?(shift, :ended)
    @shift = Shift.new
    @shift.shiftdate = Date.current + 1.day if DateTime.current.hour == 23
  end

  def create_shift
    shiftdate = (params[:shift]["shiftdate(1i)"].to_s+"-"+params[:shift]["shiftdate(2i)"].to_s+"-"+params[:shift]["shiftdate(3i)"].to_s).to_date

    # Validate shift with schedule and actual time of start
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month(current_user.department_id, shiftdate.year, shiftdate.month)
    @schedule_shift = @template.schedule_shifts.where(:number => params[:shift][:number]).first unless @template.nil?
    if @schedule_shift.nil?
      flash[:error] = "Wrong shift [number]"
      redirect_to start_shift_events_path and return
    end
    cell = @schedule_shift.schedule_cells.find_by_day_and_user_id(shiftdate.day, current_user.identifier)
    if cell.nil?
      flash[:error] = "Wrong shift [day]"
      redirect_to start_shift_events_path and return
    end
    # Allow to start only -2 hours or start or if the shift is not ended
    start_time = shiftdate + @schedule_shift.start.hours
    end_time =  shiftdate + @schedule_shift.end.hours
    if ((start_time.to_datetime - DateTime.current)*24).to_i > 2
      flash[:error] = "The shift will start #{((start_time.to_datetime - DateTime.current)*24).to_i} hours later"
      redirect_to start_shift_events_path and return
    end
    if DateTime.current > end_time.to_datetime
      flash[:error] = "The shift is already over"
      redirect_to start_shift_events_path and return
    end
    @shift = Shift.find_or_create_by_shiftdate_and_number_and_user_id(shiftdate, params[:shift][:number], current_user.id)

    if @shift
      if @shift.start_event.nil?
        #add login event
        @shift.start_event = Event.login(current_user.id, DateTime.current, request.remote_ip, @shift.id)
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
    redirect_to new_self_score_events_path and return if self_score_available?(@shift, :current)
    if @shift.end_event.nil?
      #add logout event
      @shift.end_event = Event.logout(current_user.id, DateTime.current, request.remote_ip, @shift.id)
    else
      #update end event time for shift
      @event = Event.find(@shift.end_event)
      @event.update_attributes(:eventtime => DateTime.current, :ip_address => Event.ip2int(request.remote_ip))
    end
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
    @late_coming.description = params[:late_coming][:description].strip
    if @late_coming.save
      redirect_to events_path
    else
      flash[:error] = @late_coming.errors.full_messages
      redirect_to :back
    end
  end

  def processed_by_person
    params[:date_from] = (Date.current - 1.month).to_formatted_s(:date_and_time)  if !params[:date_from]
    params[:date_to] = DateTime.current.to_formatted_s(:date_and_time)  if !params[:date_to]
    params[:user_id] = (current_user.id).to_s
    @events = Event.processed_by_person(params, 0)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end

  def new_self_score
    shift_current = current_user.shifts.where("shiftdate = ?", Date.current).order(:shiftdate).order(:number).last
    shift_ended = current_user.shifts.where("shiftdate < ?", Date.current).order(:shiftdate).order(:number).last
    if self_score_available?(shift_ended, :ended)
      @self_score = SelfScore.new(:score_date => shift_ended.shiftdate)
    else
      if self_score_available?(shift_current, :current)
        @self_score = SelfScore.new(:score_date => shift_current.shiftdate)
      else
        redirect_to events_path
      end
    end
  end

  def create_self_score
    @self_score = SelfScore.new(params[:self_score])
    @self_score.user_id = current_user.id
    if @self_score.save
      redirect_to events_path
    else
      flash[:error] = @self_score.errors.full_messages
      render :new_self_score
    end
  end

  private

  def self_score_available?(shift, mode = :current)
    return false unless Department.find(current_user.department_id).self_scored?
    case mode
      when :ended
        shift = Shift.where("shiftdate <= ? ", shift.shiftdate).where('number < 10').where('id < ?', shift.id). order(:id).find_all_by_user_id(shift.user_id).last
        SelfScore.find_by_score_date_and_user_id(shift.shiftdate, current_user.id).blank?
      else
        next_shift = Shift.where(:shiftdate => shift.shiftdate).where('number < 10').where('id > ?', shift.id). order(:id).find_all_by_user_id(shift.user_id).first
        (next_shift.blank? and SelfScore.find_by_score_date_and_user_id(shift.shiftdate, current_user.id).blank?)
    end

  end

end
