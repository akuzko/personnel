class Admin::ScheduleShiftsController < ApplicationController
  def index

  end

  def show

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
      render(:update) { |p| p.call 'app.reload'}
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
    ScheduleShift.delete(params[:id])
    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload'} }
    end
  end
end
