class Admin::LogsController < ApplicationController
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
    params[:per_page] ||= current_admin.admin_settings.find_or_create_by_key('per_page').value
    params[:per_page] ||= 15

    # convert name to id
    if params[:author_id] and params[:author_id] != '' and params[:author_id].to_i == 0
      case params[:author_type]
        when 'User'
          ids = User.joins(:profile).where("(`profiles`.last_name LIKE '%#{params[:author_id]}%' OR `profiles`.first_name LIKE '%#{params[:author_id]}%')").pluck('users.id')
        when 'Admin'
          ids = Admin.where('email LIKE ?', "%#{params[:author_id]}%")
        else
          ids = [0]
      end
      @logs = Log.search(params.merge(author_id: ids))
    else
      @logs = Log.search(params)
    end




  end
end
