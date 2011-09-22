class Admin::CategoriesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    @categories = Category.search(params, params[:page], current_admin.id)

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
    redirect_to 'index' unless current_admin.manage_department(@category.department_id)
  end

  def create
    @category = Category.new(params[:category])
    redirect_to 'index' unless current_admin.manage_department(@category.department_id)
    respond_to do |format|
      if @category.save
        subject_id = @category.id
        subject_type = @category.class.name
        body = subject_type+' '+params[:action]+"\r\n"+params[subject_type.downcase.to_sym].to_a.map{|k,v| k+":"+v}.join("; ")
        current_admin.logs_entered.create(
            :body => body,
            :subject_id => subject_id,
            :subject_type => subject_type)
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
    redirect_to 'index' unless current_admin.manage_department(@category.department_id)
    respond_to do |format|
      if @category.update_attributes(params[:category])
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
    redirect_to 'index' unless current_admin.manage_department(@category.department_id)
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(admin_categories_url) }
      format.xml  { head :ok }
    end
  end
end
