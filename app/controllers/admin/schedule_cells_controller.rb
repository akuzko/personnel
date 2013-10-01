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

  ##
  # Form for setting shifts for user
  ##
  def change
    @template = ScheduleTemplate.find params[:template_id]
    @cells = params[:cells]
    render :layout => false
  end

  #def create
  #  @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
  #  @shift = ScheduleShift.find params[:shift]
  #  @template = ScheduleTemplate.find @shift.schedule_template_id
  #  @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
  #  if params[:schedule_cell][:user_id] == ''
  #    @cell.destroy
  #  else
  #    if @cell.update_attributes(params[:schedule_cell])
  #
  #    end
  #  end
  #end

  def mass_update
    cells = params[:cells].split(',')
    cell_font_weight = ((params[:is_modified] || params[:responsible]) and params[:user_id] != '') ? 'bold' : ''
    cell_font_color = (params[:responsible] and params[:user_id] != '') ? "##{ScheduleStatus.find_or_create_by_name('Shift Leader').color}" : '#000000'
    if !params[:additional_attributes].blank? and params[:user_id] != ''
      cell_color = "##{ScheduleStatus.find_by_id(params[:additional_attributes]).color}"
    else
      cell_color = ''
    end
    cells.each do |c|
      match = c.match(/cell_([0-9]+)_([0-9]+)_([0-9]+)/)

      @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(match[1], match[2], match[3])

      @shift = ScheduleShift.find match[1]
      @template = ScheduleTemplate.find @shift.schedule_template_id
      if params[:user_id] == ''
        if @cell.date == Date.current
          Log.add(User.find_by_identifier_and_active(@cell.user_id, true), @cell, params.merge(action: 'toggle_exclude',excluded: "true by admin #{current_admin.email}, date: #{@cell.date}"))
        end
        @cell.destroy
      else
        @cell.update_attributes({
              'responsible' => params[:responsible],
              'additional_attributes' => params[:additional_attributes],
              'user_id' => params[:user_id],
              'is_modified' => params[:is_modified],
              'exclude' => false
            })
        if @cell.date == Date.current
          Log.add(User.find_by_identifier_and_active(params[:user_id], true), @cell, params.merge(action: 'toggle_exclude',excluded: "false by admin #{current_admin.email}"))
        end
      end
    end
    render(:update) do |page|
      #page["#overlay"].dialog("close")
      page.call 'app.repaint_selected_cells', params[:user_id], cell_font_weight, cell_font_color, cell_color
      page.call 'app.check_month', @template.id
      page.call 'app.show_users_admin'
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
    lines = params[:schedule].split("\r\n")
    k = 0
    hash = Hash.new

    lines.each do |l|
      hash[k+=1] = l.split("\t", -1)
    end

    shift_id  = params[:cell][:schedule_shift_id].to_i
    line      = params[:cell][:line].to_i
    day       = params[:cell][:day].to_i

    shift       = ScheduleShift.find(shift_id)
    template    = ScheduleTemplate.find(shift.schedule_template_id)
    month_days  = (Date.new(template.year,12,31).to_date<<(12-template.month)).day

    array = hash.sort

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
