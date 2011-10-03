class Admin::ScheduleShiftsController < ApplicationController
  def index

  end

  def show
    @shift = ScheduleShift.find(params[:id])
    @template = ScheduleTemplate.find @shift.schedule_template_id
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_by_name('Shift Leader').color
    render :partial => 'shared/shift_show_admin', :layout => false, :locals => {:shift => @shift}
  end

  def new
    @shift = ScheduleShift.new()
    @shift.schedule_template_id = params[:template]
    render :layout => false
  end

  def create
    @shift = ScheduleShift.new(params[:schedule_shift])
    if @shift.save
      render(:update) { |p| p.call 'app.reload'}
    else
      message = '<p>' + @shift.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#shift_flash'].parents(0).show
        page['#shift_flash'].html message
      end
    end
  end

  def edit
    @shift = ScheduleShift.find(params[:id])
    render :layout => false
  end

  def update
    @shift = ScheduleShift.find(params[:id])
    if @shift.update_attributes(params[:schedule_shift])
      render(:update) do |p|
        p.call 'app.reload_shift_admin', params[:id]
        p.call 'app.check_month', @shift.schedule_template_id
      end
    else
      message = '<p>' + @shift.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#shift_flash'].parents(0).show
        page['#shift_flash'].html message
      end
    end
  end

  def destroy
    @shift = ScheduleShift.find(params[:id])
    @shift.destroy
    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload'} }
    end
  end
end
