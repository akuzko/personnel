class Admin::DepartmentsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions
  layout 'admin'

  def check_permissions
    if !current_admin.super_user?
      flash[:error] = "You dont have permissions to view this page"
      redirect_to admin_users_path
    end
  end

  # GET /departments
  # GET /departments.xml
  def index
    @departments = Department.paginate :page => params[:page], :order => 'name DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @departments }
    end
  end

  # GET /departments/1
  # GET /departments/1.xml
  def show
    @department = Department.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @department }
    end
  end

  # GET /departments/new
  # GET /departments/new.xml
  def new
    @department = Department.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @department }
    end
  end

  # GET /departments/1/edit
  def edit
    @department = Department.find(params[:id])
  end

  # POST /departments
  # POST /departments.xml
  def create
    @department = Department.new(params[:department])

    respond_to do |format|
      if @department.save
        Log.add_by_admin(current_admin, @department, params)
        if params[:permissions].is_a? Array
          params[:permissions].each do |d|
            DepartmentPermission.find_or_create_by_department_id_and_permission_id(@department.id,d.to_i)
          end
        end
        format.html { redirect_to([:admin, @department], :notice => 'Department was successfully created.') }
        format.xml  { render :xml => @department, :status => :created, :location => @department }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /departments/1
  # PUT /departments/1.xml
  def update
    @department = Department.find(params[:id])
    params[:previous_attributes] = @department.attributes

    old_permissions = @department.permissions.map{|d|d.id.to_s}
    if old_permissions != params[:permissions]
      old_permissions.each do |d|
        unless (params[:permissions].is_a?(Array) && params[:permissions].include?(d))
          users = User.find_all_by_department_id @department.id
          users.each do |u|
            UserPermission.find_by_user_id_and_permission_id(u.id, d.to_i).destroy
          end
          DepartmentPermission.find_by_department_id_and_permission_id(@department.id,d.to_i).destroy
        end
      end
      if params[:permissions]
        new_permissions = params[:permissions] - old_permissions
        new_permissions.each do |d|
          DepartmentPermission.find_or_create_by_department_id_and_permission_id(@department.id,d.to_i)
        end
      end
    end

    respond_to do |format|
      if @department.update_attributes(params[:department])
        Log.add_by_admin(current_admin, @department, params)
        format.html { redirect_to([:admin, @department], :notice => 'Department was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.xml
  def destroy
    @department = Department.find(params[:id])
    Log.add_by_admin(current_admin, @department, params)
    @department.destroy

    respond_to do |format|
      format.html { redirect_to(admin_departments_url) }
      format.xml  { head :ok }
    end
  end
end
