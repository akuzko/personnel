class Admin::ShiftsController < ApplicationController
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
    @shifts = Shift.joins('JOIN users ON shifts.user_id = users.id').search(params, current_admin.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @shifts }
    end
  end

  def show

  end

  def new
    @shift = Shift.new
    render :layout => false
  end

  def edit
    @shift = Shift.find(params[:id])
    render :layout => false
  end

  def create
    @shift = Shift.new(params[:shift])
    if @shift.save
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @shift.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#shift_flash'].parents(0).show
        page['#shift_flash'].html message
      end
    end

  end

  def update
    @shift = Shift.find(params[:id])

    if @shift.update_attributes(params[:shift])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
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
    @shift = Shift.find(params[:id])
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end

  def available_shift_numbers
    @date = params[:date].to_date
    user = User.find(params[:user_id])
    @template = ScheduleTemplate.find_by_department_id_and_year_and_month(user.department_id, @date.year, @date.month)
    @shifts = @template.schedule_shifts.where('number < 10').order(:number) unless @template.nil?

    # user's shifts
    @shift_numbers = []
    @shifts.each do |shift|
      if shift.schedule_cells.find_all_by_user_id_and_day(user.identifier, @date.day).count > 0
        @shift_numbers.push ["#{shift.number} (#{shift.start}:00-#{shift.end}:00)", shift.number]
      end
    end

    # selected shift number
    shift = @shifts.where('start<=? and end>?', (Time.now.hour + 2), Time.now.hour).last
    @selected_number = shift.number unless shift.nil?
    render :layout => false
  end

  def missed
    @date = Date.current - 1.day
    @missed_shifts_departments = {}
    @templates = ScheduleTemplate.where('year = ?', @date.year).where('month = ?', @date.month).where('visible = 1').all
    @templates.each do |template|
      if current_admin.manage_department(template.department_id)
        missed_shifts = []
        department = Department.find(template.department_id)
        admins = department.admins.map(&:email)
        template.schedule_shifts.each do |shift|
          if shift.number < 10
            shift.schedule_cells.each do |cell|
              if !cell.user_id.nil? && cell.day == @date.day
                user = User.find_by_identifier_and_active(cell.user_id, 1)
                count = Shift.find_all_by_user_id_and_number_and_shiftdate(user.id, shift.number, @date).count
                missed_shifts.push [user.full_name, @date, shift.number, shift.start, shift.end] if count == 0
              end
            end
          end
        end
        if !missed_shifts.empty?
          @missed_shifts_departments[department.name] = {}
          @missed_shifts_departments[department.name][:shifts] = missed_shifts
          @missed_shifts_departments[department.name][:admins] = admins
        end
      end
    end
  end
end
