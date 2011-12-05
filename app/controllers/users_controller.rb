class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile, :only => [:find]
  layout 'user'

  def edit
    @user = User.find current_user.id
  end

  def update
    @user = User.find current_user.id
    params[:previous_attributes] = @user.attributes
    if !params[:user][:password].nil? && params[:user][:password].empty?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        sign_in(@user, :bypass => true)
        Log.add(current_user, @user, params)
        format.html { redirect_to(@user, :notice => t('personnel.user.User was successfully updated', :default => 'User was successfully updated')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def view
    @user = User.with_data.find(params[:id])
    @department = Department.find @user.department_id

    #redirect_to 'index' unless current_admin.manage_department(@user.department_id)
    respond_to do |format|
      format.html { render :partial => 'show' if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def show
    @user = User.find current_user.id
    flash[:error] = "Please upload your picture" if !@user.avatar.exists?
    flash[:error] = "Please update your profile" if @user.profile.first_name.nil?
    flash[:error] = "Please add your address" if @user.addresses.empty?
    flash[:error] = "Please update your contact information" if @user.contact.cell1.nil?
  end

  def edit_data
    user = User.find current_user.id
    render :partial => params[:data], :object => user.send(params[:data]), :locals => {:user => user}
  end

  def update_data
    user = User.find current_user.id
    data = user.send(params[:data])
    params[:previous_attributes] = data.attributes
    if data.update_attributes(params[params[:data]])
      user.sync_with_forum
      Log.add(current_user, data, params)
      render(:update){ |p| p.call 'app.reload_section', params[:data]}
    else
      message = '<p>' + data.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#'+params[:data]+'_flash'].parents(0).show
        page['#'+params[:data]+'_flash'].html message
      end
    end
  end

  def list
    users = User.where("identifier != '' AND active = 1").order("identifier")
    @u = users.to_a.in_groups_of(2)
    render :layout => 'lists'
  end

  def display_addresses
    @user = User.find current_user.id
    render '_show_addresses.html', :layout => false
  end

  def display_section
    @user = User.find current_user.id
    render '_show_'+params[:section]+'.html', :layout => false
  end

  def find
    @user = User.find current_user.id
    params[:per_page] ||= 15
    @users = User.with_data.active.search(params)
  end

  def crop
    @user = User.find current_user.id
    if !@user.avatar.exists?
      flash[:error] = "Please upload a picture first."
      redirect_to edit_user_url(@user)
    end
  end

  def delivery
    if !params[:date]
      date = Date.current
    else
      date = (params[:date][:year].to_s+"-"+params[:date][:month].to_s+"-"+params[:date][:day].to_s).to_date
    end
    params[:date] = date

    #Out 24:00
    out_ids = []
    templates = ScheduleTemplate.find_all_by_year_and_month date.year, date.month
    templates.each do |tpl|
      tpl.schedule_shifts.where('number < 10').where('end = 24').each do |shift|
        shift.schedule_cells.each do |cell|
          out_ids.push cell.user_id if cell.day == date.day && cell.user_id? && !cell.exclude
        end
      end
    end
    @users_out = User.with_data.active.order(:identifier).where("identifier IN (#{out_ids.map { |d| d }.join(',')})") if !out_ids.empty?

    #In 0:00
    in_ids = []
    date = date + 1.day
    templates = ScheduleTemplate.find_all_by_year_and_month date.year, date.month
    templates.each do |tpl|
      tpl.schedule_shifts.where('number < 10').where('start = 0').each do |shift|
        shift.schedule_cells.each do |cell|
          in_ids.push cell.user_id if cell.day == date.day && cell.user_id? && !cell.exclude
        end
      end
    end
    @users_in = User.with_data.active.order(:identifier).where("identifier IN (#{in_ids.map { |d| d }.join(',')})") if !in_ids.empty?

    render :layout => 'mobile'
  end
end
