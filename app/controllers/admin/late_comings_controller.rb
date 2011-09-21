class Admin::LateComingsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions, :except => :delivery
  layout 'admin'

  def check_permissions
    redirect_to delivery_admin_users_path unless current_admin.super_user? || !current_admin.departments.empty?
  end

  def index
    params[:date_from] = Date.current.to_formatted_s(:date_only)  if !params[:date_from]
    params[:date_to] = Date.current.to_formatted_s(:date_only)  if !params[:date_to]


    @late_comings = LateComing.joins('JOIN users ON late_comings.user_id = users.id').joins('JOIN profiles ON profiles.user_id = users.id').joins('JOIN shifts ON late_comings.shift_id = shifts.id').search(params, params[:page], current_admin.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end

  def edit
    @late_coming = LateComing.find(params[:id])
    render :layout => false
  end

  def update
    @late_coming = LateComing.find(params[:id])

    if @late_coming.update_attributes(params[:late_coming])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @late_coming.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#late_coming_flash'].parents(0).show
        page['#late_coming_flash'].html message
      end
    end
  end

  def destroy
    @late_coming = LateComing.find(params[:id])
    @late_coming.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end
end
