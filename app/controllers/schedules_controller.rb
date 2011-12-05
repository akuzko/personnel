class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile
  layout 'user'

  def show
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = User.find(current_user.id).department_id unless params[:department_id]
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month_and_visible(params[:department_id], params[:date].year, params[:date].month, 1)
    if @template.nil?
      flash[:error] = "No schedule available at this time"
      redirect_to new_schedule_path
      return
    end
    @users = User.order(:identifier).find_all_by_department_id_and_active params[:department_id], 1
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_by_name('Shift Leader').color
    @statuses = ScheduleStatus.order(:name).all
  end

  def new
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Time.now
    end
    params[:department_id] = @user = User.find(current_user.id).department_id unless params[:department_id]
  end

  def edit
    redirect_to user_path and return if current_user.can_edit_schedule == 0
    @template = ScheduleTemplate.find_by_id(current_user.can_edit_schedule)
    redirect_to user_path and return if @template.visible != 2
    if @template.schedule_shifts.empty?
      @previous_template = ScheduleTemplate.where('id < ?', @template.id).order('year DESC, month DESC').limit(1).find_by_department_id(params[:department_id])
      if @previous_template
        @previous_template.schedule_shifts.each do |shift|
          @shift = ScheduleShift.create(:schedule_template_id => @template.id, :lines => shift.lines, :number => shift.number, :start => shift.start, :end => shift.end)
          @shift.save
        end
      end
    end
    params[:visible] = @template.visible
    @users = User.order(:identifier).find_all_by_department_id_and_active @template.department_id, 1
    @days_in_month = Time.days_in_month(@template.month, @template.year)
    @shift_leader_color = ScheduleStatus.find_or_create_by_name('Shift Leader').color
    @statuses = ScheduleStatus.order(:name).all
  end

  def update_cell
    @cell = ScheduleCell.find_or_create_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    if current_user.can_edit_schedule == 0 || @template.visible != 2
      render(:update) do |page|
        page.call 'app.reload'
      end
      return
    end
    @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
    id = "#cell_#{@cell.schedule_shift_id}_#{@cell.line}_#{@cell.day}"
    cell_color_default = (1..5) === @wday ? 'ffffff' : 'FBB999'
    cell_color_default = @shift.number == 10 ? 'eeeeee' : cell_color_default
    if @cell.user_id == current_user.identifier
      @cell.destroy
      render(:update) do |page|
        page[id].css('background-color', '#'+cell_color_default)
        page[id].css('color', '#000000')
        page[id].css('font-weight', '')
        page[id].html ''
      end
    else
      if (@cell.user_id.nil? || @cell.user_id == '')
        if @cell.update_attribute(:user_id, current_user.identifier)
          render(:update) do |page|
            page[id].css('background-color', '#'+cell_color_default)
            page[id].css('color', '#000000')
            page[id].css('font-weight', '')
            page[id].html @cell.user_id
          end
        end
      else
        render(:update) do |page|
          page[id].html @cell.user_id
          #page.call 'alert("Error! The cell is already taken")'
          page << 'alert("Error! The cell is already taken");'
        end
      end
    end
  end

  def toggle_exclude
    @cell = ScheduleCell.find_by_schedule_shift_id_and_line_and_day(params[:shift], params[:line], params[:day])
    if @cell.nil?
      render(:update) do |page|
        message = "<div class='message error'><p>The cell is empty!</p></div>"
        page['.flash'].parents(0).show
        page['.flash'].html message
      end
      return
    end
    @shift = ScheduleShift.find params[:shift]
    @template = ScheduleTemplate.find @shift.schedule_template_id
    @wday = Date.parse("#{@template.year}-#{@template.month}-#{params[:day]}").wday
    id = "#cell_#{@cell.schedule_shift_id}_#{@cell.line}_#{@cell.day}"
    if @cell.user_id == current_user.identifier && @cell.update_attribute(:exclude, !@cell.exclude)
      render(:update) do |page|
        if @cell.exclude
          page[id].css('text-decoration', 'line-through')
        else
          page[id].css('text-decoration', 'none')
        end
        message = "<div class='message notice'><p>Delivery status is changed</p></div>"
        page['.flash'].parents(0).show
        page['.flash'].html message
      end
    else
      render(:update) do |page|
        message = "<div class='message error'><p>This cell is not owned by you!</p></div>"
        page['.flash'].parents(0).show
        page['.flash'].html message
      end
    end
    #  @cell.destroy
    #  render(:update) do |page|
    #    page[id].css('background-color', '#'+cell_color_default)
    #    page[id].css('color', '#000000')
    #    page[id].css('font-weight', '')
    #    page[id].html ''
    #  end
    #else
    #  if (@cell.user_id.nil? || @cell.user_id == '')
    #    if @cell.update_attribute(:user_id, current_user.identifier)
    #      render(:update) do |page|
    #        page[id].css('background-color', '#'+cell_color_default)
    #        page[id].css('color', '#000000')
    #        page[id].css('font-weight', '')
    #        page[id].html @cell.user_id
    #      end
    #    end
    #  else
    #    render(:update) do |page|
    #      page[id].html @cell.user_id
    #      #page.call 'alert("Error! The cell is already taken")'
    #      page << 'alert("Error! The cell is already taken");'
    #    end
    #  end
    #end
  end

end