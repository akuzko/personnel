class Admin::CategoriesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
    params[:per_page] ||= 15
    @categories = Category.search(params, current_admin.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  def show
    @category = Category.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  def edit
    @category = Category.find(params[:id])
    redirect_to admin_categories_path unless current_admin.manage_department(@category.department_id)
  end

  def create
    @category = Category.new(params[:category])
    redirect_to admin_categories_path and return unless current_admin.manage_department(@category.department_id)
    respond_to do |format|
      if @category.save
        Log.add(current_admin, @category, params)
        format.html { redirect_to([:admin, @category], :notice => 'Category was successfully created.') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @category = Category.find(params[:id])
    redirect_to admin_categories_path and return unless current_admin.manage_department(@category.department_id)
    params[:previous_attributes] = @category.attributes
    respond_to do |format|
      if @category.update_attributes(params[:category])
        Log.add(current_admin, @category, params)
        format.html { redirect_to([:admin, @category], :notice => 'Category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    redirect_to admin_categories_path and return unless current_admin.manage_department(@category.department_id)
    Log.add(current_admin, @category, params)
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(admin_categories_url) }
      format.xml  { head :ok }
    end
  end
end
