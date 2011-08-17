class Admin::ScheduleCellsController < ApplicationController
  def index

  end

  def show
  end

  def new
    @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    render :layout => false
  end

  #def create
  #  @cell = ScheduleCell.new(params[:schedule_cell])
  #  if @cell.save
  #    render(:update) { |p| p.call 'app.reload'}
  #  else
  #    message = '<p>' + @cell.errors.full_messages.join('</p><p>') + '</p>'
  #    render(:update) do |page|
  #      page['#cell_flash'].parents(0).show
  #      page['#cell_flash'].html message
  #    end
  #  end
  #end

  #def edit
  #  @cell = ScheduleCell.find(params[:id])
  #  render :layout => false
  #end
  #
  def update
    @cell = ScheduleCell.find(params[:id])
    id = "#cell_#{@cell.schedule_shift_id}_#{@cell.line}_#{@cell.day}"
    if params[:schedule_cell][:user_id] == ''
      @cell.destroy
      render(:update) do |page|
        page[id].css('background-color', '#FFFFFF')
        page[id].css('color', '#000000')
        page[id].css('font-weight', '')
        page[id].html ''
        page["#overlay"].dialog("close")
        page.call 'app.check_day', @cell.schedule_shift_id, @cell.day
        page.call 'app.show_users_admin', ScheduleShift.find(@cell.schedule_shift_id).schedule_template_id
      end
    else
      if @cell.update_attributes(params[:schedule_cell])
        render(:update) do |page|
          if @cell.additional_attributes?
            page[id].css('background-color', '#'+ScheduleStatus.find_by_id(@cell.additional_attributes).color)
          else
            page[id].css('background-color', '#FFFFFF')
          end
          if @cell.responsible?
            page[id].css('color', '#'+ScheduleStatus.find_by_name('shift_leader').color)
          else
            page[id].css('color', '#000000')
          end
          if @cell.responsible? || @cell.is_modified?
            page[id].css('font-weight', 'bold')
          else
            page[id].css('font-weight', '')
          end
          page[id].html @cell.user_id
          page["#overlay"].dialog("close")
          page.call 'app.check_day', @cell.schedule_shift_id, @cell.day
          page.call 'app.show_users_admin', ScheduleShift.find(@cell.schedule_shift_id).schedule_template_id
        end
      else
        message = '<p>' + @cell.errors.full_messages.join('</p><p>') + '</p>'
        render(:update) do |page|
          page['#cell_flash'].parents(0).show
          page['#cell_flash'].html message
        end
      end
    end
  end

  def destroy
    ScheduleCell.delete(params[:id])
    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload' } }
    end
  end
end
