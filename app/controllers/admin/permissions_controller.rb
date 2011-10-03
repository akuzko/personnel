class Admin::PermissionsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    @permissions = Permission.all

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @permissions }
    end
  end

  def new
    @permission = Permission.new
    render :layout => false
  end

  def create
    @permission = Permission.new(params[:permission])

    if @permission.save
      Log.add(current_admin, @permission, params)
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @permission.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#permission_flash'].parents(0).show
        page['#permission_flash'].html message
      end
    end
  end

  def edit
    @permission = Permission.find(params[:id])
    render :layout => false
  end

  def update
    @permission = Permission.find(params[:id])
    params[:previous_attributes] = @permission.attributes
    if @permission.update_attributes(params[:permission])
      Log.add(current_admin, @permission, params)
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @permission.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#permission_flash'].parents(0).show
        page['#permission_flash'].html message
      end
    end
  end

  def destroy
    @permission = Permission.find(params[:id])
    Log.add(current_admin, @permission, params)
    @permission.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end
end