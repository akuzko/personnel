class Admin::EventsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    params[:date_from] = (DateTime.current - 2.hour).to_formatted_s(:date_and_time)  if !params[:date_from]
    params[:date_to] = DateTime.current.to_formatted_s(:date_and_time)  if !params[:date_to]
    params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
    params[:per_page] ||= 15

    @events = Event.joins('JOIN users ON events.user_id = users.id').search(params, current_admin.id)

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
    @event.ip_address = Event.ip2int(request.remote_ip)

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
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end

  def processed_total
    params[:date_from] = (Date.current - 1.month).to_formatted_s(:date_only)  if !params[:date_from]
    params[:date_to] = Date.current.to_formatted_s(:date_only)  if !params[:date_to]
    @events = Event.processed_total(params, current_admin, true)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end

  def processed_by_person
    params[:date_from] = (Date.current - 1.month).to_formatted_s(:date_and_time)  if !params[:date_from]
    params[:date_to] = DateTime.current.to_formatted_s(:date_and_time)  if !params[:date_to]
    @events = Event.processed_by_person(params, current_admin)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end

  def processed_by_day_of_week
    params[:date_from] = (Date.current - 1.month).to_formatted_s(:date_only)  if !params[:date_from]
    params[:date_to] = Date.current.to_formatted_s(:date_only)  if !params[:date_to]
    @events = Event.processed_by_day_of_week(params, current_admin, true)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end
end
