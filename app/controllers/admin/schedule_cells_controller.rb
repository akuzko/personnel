class Admin::ScheduleCellsController < ApplicationController
  def index

  end

  def show
  end

  def new
    @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
    render :layout => false
  end

  def create
    @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
    id = "#cell_#{@cell.schedule_shift_id}_#{@cell.line}_#{@cell.day}"
    cell_color_default = (1..5) === @wday  ? 'ffffff' : 'FBB999'
    if params[:schedule_cell][:user_id] == ''
      @cell.destroy
      render(:update) do |page|
        page[id].css('background-color', '#'+cell_color_default)
        page[id].css('color', '#000000')
        page[id].css('font-weight', '')
        page[id].html ''
        page[id].removeClass('selected')
        page["#overlay"].dialog("close")
        #page.call 'app.show_users_admin', ScheduleShift.find(@cell.schedule_shift_id).schedule_template_id
      end
    else
      if @cell.update_attributes(params[:schedule_cell])
        render(:update) do |page|
          if @cell.additional_attributes?
            page[id].css('background-color', '#'+ScheduleStatus.find_by_id(@cell.additional_attributes).color)
          else
            page[id].css('background-color', '#'+cell_color_default)
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
          page[id].removeClass('selected')
          #page.call 'app.show_users_admin', ScheduleShift.find(@cell.schedule_shift_id).schedule_template_id
        end
      end
    end
  end

  def mass_update
    render(:update) do |page|
      page.call 'app.mass_update', params[:schedule_cell][:responsible], params[:schedule_cell][:additional_attributes], params[:schedule_cell][:user_id], params[:schedule_cell][:is_modified]
      page["#overlay"].dialog("close")
    end
  end

  def destroy
    ScheduleCell.delete(params[:id])
    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload' } }
    end
  end

end
