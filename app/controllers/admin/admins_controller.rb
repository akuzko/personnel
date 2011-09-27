class Admin::AdminsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions
  layout 'admin'

  def check_permissions
    if !current_admin.super_user?
      flash[:error] = "You dont have permissions to view this page"
      redirect_to admin_users_path
    end
  end

  def index
    @admins = Admin.paginate :page => params[:page], :per_page => 20, :order => 'email DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admins }
    end
  end

  def show
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  def new
    @admin = Admin.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  def edit
    @admin = Admin.find(params[:id])
  end

  def create
    @admin = Admin.new(params[:admin])
    respond_to do |format|
      if @admin.save
        if params[:departments].is_a? Array
          params[:departments].each do |d|
            AdminDepartment.find_or_create_by_admin_id_and_department_id(@admin.id,d.to_i)
          end
        end
        Log.add(current_admin, @admin, params)
        Log.add_set(current_admin, @admin, params, 'departments')
        format.html { redirect_to([:admin, @admin], :notice => 'Admin was successfully created.') }
        format.xml  { render :xml => @admin, :status => :created, :location => @admin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @admin = Admin.find(params[:id])
    params[:previous_attributes] = @admin.attributes
    old_departments = @admin.departments.map{|d|d.id.to_s}
    if old_departments != params[:departments]
      old_departments.each do |d|
        AdminDepartment.find_by_admin_id_and_department_id(@admin.id,d.to_i).destroy unless (params[:departments].is_a?(Array) && params[:departments].include?(d))
      end
      if params[:departments]
        new_departments = params[:departments] - old_departments
        new_departments.each do |d|
          AdminDepartment.find_or_create_by_admin_id_and_department_id(@admin.id,d.to_i)
        end
      end
    end
    if params[:admin][:password].empty?
      params[:admin].delete(:password)
      params[:admin].delete(:password_confirmation)
    end
    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        Log.add(current_admin, @admin, params)
        Log.add_set(current_admin, @admin, params, 'departments')
        format.html { redirect_to([:admin, @admin], :notice => 'Admin was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    Log.add(current_admin, @admin, params)
    @admin.destroy

    respond_to do |format|
      format.html { redirect_to(admin_admins_url) }
      format.xml  { head :ok }
    end
  end

  def settings_edit
    @admin = Admin.find(current_admin.id)
  end

  def settings_update
    @admin = Admin.find(current_admin.id)
  end
end
