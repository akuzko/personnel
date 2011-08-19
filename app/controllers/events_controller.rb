class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_shift_started, :except => [:start_shift, :new_shift, :available_shift_numbers]
  layout 'user'

  def index
    @events = Event.find_all_by_user_id(current_user.id).paginate :page => params[:page], :per_page => 15

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
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

    if @event.save
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

  def update
    @event = Event.find(params[:id])
    @event.user_id = current_user.id

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
    @shift = Shift.new
  end

  def new_shift
    shiftdate = (params[:shift]["shiftdate(1i)"].to_s+"-"+params[:shift]["shiftdate(2i)"].to_s+"-"+params[:shift]["shiftdate(3i)"].to_s).to_date
    @shift = Shift.find_or_create_by_shiftdate_and_number_and_user_id(shiftdate, params[:shift][:number], current_user.id)
    if @shift
      if @shift.start_event.nil?
        #add login event
        @shift.start_event = Event.login(current_user.id)
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
    @shift.end_event = Event.logout(current_user.id)
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
    shift = @shifts.where('start<=? and end>?', (Time.now.hour + 2), Time.now.hour).first
    @selected_number = shift.number unless shift.nil?
    render :layout => false
  end

end
