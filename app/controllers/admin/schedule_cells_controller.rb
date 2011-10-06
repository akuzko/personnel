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
    cell_color_default = @shift.number == 10  ? 'eeeeee' : cell_color_default
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
            page[id].css('color', '#'+ScheduleStatus.find_by_name('Shift Leader').color)
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

  def batch_new
    @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
    render :layout => false
  end

  def batch_update
    ap params[:schedule]
    lines = params[:schedule].split("\r\n")
    ap lines
    k = 0
    hash = Hash.new

    lines.each do |l|
      hash[k+=1] = l.split("\t", -1)
    end

    ap hash

    shift_id  = params[:cell][:schedule_shift_id].to_i
    line      = params[:cell][:line].to_i
    day       = params[:cell][:day].to_i

    shift       = ScheduleShift.find(shift_id)
    template    = ScheduleTemplate.find(shift.schedule_template_id)
    month_days  = (Date.new(template.year,12,31).to_date<<(12-template.month)).day

    array = hash.sort

    ap array

    array.each do |k, cells|
      cells.each do |c|
        if day <= month_days
          cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(shift_id, line, day)
          cell.update_attributes({:schedule_shift_id => shift_id, :line => line, :day => day, :user_id => c})
          day += 1
        end
      end
      if shift.lines > line
        line += 1
      else
        next_shift = ScheduleShift.find_by_schedule_template_id_and_number(template.id, shift.number.next)
        if !next_shift.nil?
          shift_id = next_shift.id
          shift = next_shift
          line = 1
        elsif shift.number != 10
          next_shift = ScheduleShift.find_by_schedule_template_id_and_number(template.id, 10)
          shift_id = next_shift.id
          shift = next_shift
          line = 1
        else
          break
        end
      end
      day = params[:cell][:day].to_i
    end

    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload' } }
    end
  end

  def destroy
    ScheduleCell.delete(params[:id])
    respond_to do |format|
      format.js { render() { |p| p.call 'app.reload' } }
    end
  end

end
