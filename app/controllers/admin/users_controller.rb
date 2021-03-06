# encoding: utf-8
class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    if !params[:sort_by]
      params[:active] = "1"
      params[:employed] = "1"
    end
    if params[:export]
      params[:per_page] = User.count
      params[:page] = 1
    else
      params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
      params[:per_page] ||= 15
    end

    @users = User.with_data.search_by_admin(params, current_admin.id)

    if params[:export]
      headers['Content-Type'] = "application/vnd.ms-excel"
      headers['Content-Disposition'] = 'attachment; filename="users.xls"'
      headers['Cache-Control'] = ''
      render 'export_users', :layout => false
    end
  end

  def list
    users = User.where("identifier != '' AND active = 1").order("identifier")
    @u = users.to_a
    render :layout => 'lists'
  end

  def delivery
    if !params[:date]
      date = Date.current
    else
      date = (params[:date][:year].to_s+"-"+params[:date][:month].to_s+"-"+params[:date][:day].to_s).to_date
    end
    params[:date] = date

    @taxi_route = TaxiRoute.find_by_traced(params[:date])

    #Out 24:00
    out_ids = []
    templates = ScheduleTemplate.includes(schedule_shifts: :schedule_cells).find_all_by_year_and_month date.year, date.month
    templates.each do |tpl|
      tpl.schedule_shifts.find_all{|s| s.number < 10 and s.end == 24}.each do |shift|
        shift.schedule_cells.each do |cell|
          out_ids.push cell.user_id if cell.day == date.day && cell.user_id? && !cell.exclude && User.find_by_identifier_and_deliverable_and_active(cell.user_id, true, true)
        end
      end
    end
    @users_out = []
    @users_out = User.with_data.deliverable.active.order(:identifier).where("identifier IN (#{out_ids.map { |d| d }.join(',')})") if !out_ids.empty?

    #In 0:00
    in_ids = []
    date = date + 1.day
    templates = ScheduleTemplate.includes(schedule_shifts: :schedule_cells).find_all_by_year_and_month date.year, date.month
    templates.each do |tpl|
      tpl.schedule_shifts.find_all{|s| s.number < 10 and s.start == 0}.each do |shift|
        shift.schedule_cells.each do |cell|
          in_ids.push cell.user_id if cell.day == date.day && cell.user_id? && !cell.exclude && User.find_by_identifier_and_deliverable_and_active(cell.user_id, true, true)
        end
      end
    end
    @users_in = []
    @users_in = User.with_data.deliverable.active.order(:identifier).where("identifier IN (#{in_ids.map { |d| d }.join(',')})") if !in_ids.empty?

    @users_in_ids = in_ids
    @users_out_ids = out_ids

    if params['detailed'] == '1'
      render 'users/delivery_detailed', layout: 'mobile', format: :html
    else

      @users_out = @users_out.in_groups_of(4)
      @users_in = @users_in.in_groups_of(4)

      render 'users/delivery', layout: 'mobile', format: :html
    end
  end

  def show
    @user = User.with_data.find(params[:id])
    @department = Department.find @user.department_id

    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    respond_to do |format|
      format.html { render :partial => 'show' if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
    @department = Department.find @user.department_id
    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    @back_url = request.env["HTTP_REFERER"]
  end

  def create
    params[:user].delete(:back_url)
    @user = User.new(params[:user])
    redirect_to admin_users_url unless current_admin.manage_department(@user.department_id)
    respond_to do |format|
      if @user.save
        Log.add(current_admin, @user, params)
        format.html { redirect_to([:admin, @user], :notice => 'User was successfully created.') }
        format.xml { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @department = Department.find @user.department_id
    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    params[:previous_attributes] = @user.attributes
    @back_url = params[:user][:back_url]
    params[:user].delete(:back_url)
    if params[:user][:password].empty?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.department_id != params[:user][:department_id]
      puts "Dept changed"
      # copy permissions to department
      @new_dept = Department.find_by_id(params[:user][:department_id])
      new_permissions = @user.permissions.map(&:id) - @new_dept.permissions.map(&:id)
      new_permissions.each do |d|
        DepartmentPermission.find_or_create_by_department_id_and_permission_id(@new_dept.id,d)
      end
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        Log.add(current_admin, @user, params)
        format.html { redirect_to @back_url, :notice => 'User was successfully updated.' } #redirect_to(admin_user_url, :notice => 'User was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    Log.add(current_admin, @user, params)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url, :notice => 'User was successfully deleted.') }
      format.xml { head :ok }
    end
  end

  def edit_data
    user = User.find params[:id]
    if params[:data] == 'permissions'
      @department = Department.find user.department_id
    end
    redirect_to 'index' unless current_admin.manage_department(user.department_id)
    render :partial => params[:data], :object => user.send(params[:data]), :locals => {:user => user}
  end

  def update_data
    user = User.find params[:id]
    redirect_to 'index' unless current_admin.manage_department(user.department_id)
    data = user.send(params[:data])
    params[:previous_attributes] = data.attributes
    if data.update_attributes(params[params[:data]])
      user.sync_with_forum
      Log.add(current_admin, data, params)
      render(:update) { |p| p.call 'app.reload_section_admin', params[:id], params[:data] }
    else
      message = '<p>' + data.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#'+params[:data]+'_flash'].parents(0).show
        page['#'+params[:data]+'_flash'].html message
      end
    end
  end

  def update_permissions
    user = User.find params[:id]

    redirect_to 'index' unless current_admin.manage_department(user.department_id)

    old_permissions = user.permissions.map(&:id)

    if params[:permissions].nil?
      user_perms = UserPermission.find_all_by_user_id(user.id)
      user_perms.each do |up|
        up.destroy
      end
    elsif old_permissions != params[:permissions]
      old_permissions.each do |p|
        unless (params[:permissions].include?(p))
          UserPermission.find_by_user_id_and_permission_id(user.id, p).destroy
        end
      end
      new_permissions = params[:permissions] - old_permissions
      new_permissions.each do |p|
        UserPermission.find_or_create_by_user_id_and_permission_id(user.id, p.to_i)
      end
    end
    Log.add_set(current_admin, user, params, 'permissions')

    render(:update) { |p| p.call 'app.reload_section_admin', params[:id], params[:data] }
  end

  def display_addresses
    @user = User.find params[:id]
    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    render '_show_addresses.html', :layout => false
  end

  def display_section
    @user = User.find params[:id]
    if params[:section] == 'permissions'
      @department = Department.find(@user.department_id)
    end
    redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    render '_show_'+params[:section]+'.html', :layout => false
  end

  def crop
    @user = User.find params[:id]
    if !@user.avatar.exists?
      flash[:error] = "Please upload a picture first."
      redirect_to edit_admin_user_url
    end
  end

  def update_crop
    @user = User.find params[:id]
    respond_to do |format|
      if @user.crop_avatar(params[:user])
        format.html { redirect_to(admin_user_url, :notice => 'User\'s picture was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "crop" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def clear_avatar
    @user = User.find params[:id]
    @user.avatar = nil
    @user.save
    flash[:notice] = "Avatar was successfully removed"
    redirect_to admin_users_url
  end

  def working_shifts
    if params[:date]
      params[:date] = Date.parse(params[:date]["year"].to_s+"-"+params[:date]["month"].to_s+"-1")
    else
      params[:date] = Date.current
    end
    @users = {}
    ScheduleTemplate.find_all_by_year_and_month(params[:date].year, params[:date].month).each do |template|
      if params[:department_id] && !params[:department_id].empty?
        redirect_to working_shifts_admin_users_url and return unless current_admin.manage_department(params[:department_id])
        @users[template] = User.includes(:profile).order('profiles.last_name').find_all_by_department_id_and_active(template.department_id, 1) if params[:department_id].to_i == template.department_id
      else
        @users[template] = User.includes(:profile).order('profiles.last_name').find_all_by_department_id_and_active(template.department_id, 1) if current_admin.manage_department(template.department_id)
      end
    end
    if params[:export]
      headers['Content-Type'] = "application/vnd.ms-excel"
      headers['Content-Disposition'] = 'attachment; filename="working_shifts.xls"'
      headers['Cache-Control'] = ''
      render 'export_working_shifts.html', :layout => false
    end
  end

  def t_shirts
    params[:active] = "1"
    params[:employed] = "1"
    params[:sort_by] = :department_id
    @users = User.t_shirts(current_admin.id)
  end

  def get_for_department
    @department = Department.find_by_id params['did']
    @users = User.active.find_all_by_department_id @department.id
    @permission = Permission.find_by_id params['pid']
    render 'get_for_department.html', :layout => false
  end

  def update_for_department
    DepartmentPermission.find_or_create_by_department_id_and_permission_id(params["department"]["id"].to_i, params["permission"]["id"].to_i)
    if !params["users"].nil?
      params["users"].each do |id|
        UserPermission.find_or_create_by_user_id_and_permission_id(id, params["permission"]["id"].to_i)
      end
    end
    render(:update) do |page|
      message = "<div class='message notice'><p>Account updated successfuly</p></div>"
      page['.flash'].parents(0).show
      page['.flash'].html message
    end
  end

  def fire_reasons
    @users = User.includes(:fire_reason).select('count(*) as total, fire_reason_id').where('fired_at IS NOT NULL')
    @users = @users.where('department_id IN (?)', params[:departments]) # unless params[:departments].blank?
    @users = @users.where('fired_at >= ?', params[:date_from]) unless params[:date_from].blank?
    @users = @users.where('fired_at <= ?', params[:date_to]) unless params[:date_to].blank?
    @users = @users.group(:fire_reason_id)
  end

  def fired_people
    params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
    params[:per_page] ||= 15

    params[:sort_by] ||= :full_name
    sort_by = {
        :fired_at => '`users`.fired_at',
        :reason => '`users`.fire_reason_id',
        :full_name => '`profiles`.last_name'
    }

    @users = User.includes(:fire_reason, :profile, :department).where('fired_at IS NOT NULL')
    @users = @users.where('department_id IN (?)', params[:departments]) unless params[:departments].blank?
    @users = @users.where('fired_at >= ?', params[:date_from]) unless params[:date_from].blank?
    @users = @users.where('fired_at <= ?', params[:date_to]) unless params[:date_to].blank?
    @users = @users.paginate :per_page => [params[:per_page].to_i, 20].max, :page => params[:page],
                                 :order => "#{sort_by[params[:sort_by].to_sym]} #{params[:sort_order]}"
  end

end
