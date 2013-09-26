class Admin::LateComingsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    params[:date_from] = Date.current.to_formatted_s(:date_only) if !params[:date_from]
    params[:date_to] = Date.current.to_formatted_s(:date_only) if !params[:date_to]
    params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
    params[:per_page] ||= 15

    @late_comings = LateComing.search(params, current_admin.id)
    @late_comings_grouped = @late_comings.group_by(&:user_full_name)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def edit
    @late_coming = LateComing.find(params[:id])
    render :layout => false
  end

  def update
    @late_coming = LateComing.find(params[:id])

    if @late_coming.update_attributes(params[:late_coming])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @late_coming.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#late_coming_flash'].parents(0).show
        page['#late_coming_flash'].html message
      end
    end
  end

  def release
    if params[:release]
      params[:release].each do |id|
        late_coming = LateComing.find_by_id(id)
        shift = Shift.find(late_coming.shift_id)
        start_event = Event.find_by_id(shift.start_event)
        start_event.eventtime = shift.schedule_start_time rescue nil
        start_event.save
        late_coming.destroy
      end
    end
    redirect_to admin_late_comings_path
  end

  def destroy
    late_coming = LateComing.find(params[:id])
    shift = Shift.find(late_coming.shift_id)
    start_event = Event.find_by_id(shift.start_event)
    start_event.eventtime = shift.schedule_start_time rescue nil
    start_event.save
    late_coming.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end
end
