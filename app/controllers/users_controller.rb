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

  def notify
    render :layout => false
  end

  def send_notify
    message = Notify.address_changed(current_user)
    message.deliver
    render(:update) do |page|
      page['.flash'].html "<div class='message notice'><p>Email has been sent</p></div>"
      page["#overlay"].dialog("close")
    end
  end

  def show
    @user = User.find current_user.id
    flash[:error] = "Please upload your picture" if !@user.avatar.exists?
    flash[:error] = "Please update your profile" if @user.profile.first_name.nil?
    flash[:error] = "Please add your address" if @user.addresses.empty?
    flash[:error] = "Please update your contact information" if @user.contact.cell1.nil?
    forum_member = SmfMember.find_by_member_name(@user.email.gsub(/@zone3000.net/, ''))
    if forum_member
      time = Time.now + 3153600.minutes
      data = "a:4:{i:0;s:#{forum_member.id_member.to_s.size}:\"#{forum_member.id_member}\";i:1;s:40:\"#{Digest::SHA1.hexdigest(forum_member.passwd+forum_member.password_salt)}\";i:2;i:#{time.to_i};i:3;i:0;}"
      #data = 'a:4:{i:0;s:'+forum_member.id_member.to_s.size.to_s+':"'+forum_member.id_member.to_s+'";i:1;s:40:"'+Digest::SHA1.hexdigest(forum_member.passwd+forum_member.password_salt).to_s+'";i:2;i:'+time.to_i.to_s+';i:3;i:0;}'
      cookies['SMFCookie432'] = { :value => data, :expires => time, :domain => ".#{request.domain(2)}"}
    end
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
    @u = users.to_a

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
    params[:sort_by] ||= "identifier"
    params[:per_page] ||= 15
    if (!params[:identifier].nil? && !params[:identifier].empty?) ||
        (!params[:full_name].nil? && !params[:full_name].empty? && params[:full_name].length >= 3)
      @users = User.with_data.active.search(params)
    else
      flash[:error] = "Please input either a Name/Last Name or an Identifier to see the results"
    end
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

    @taxi_route = TaxiRoute.find_by_traced(params[:date])

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
    @users_out = []
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
    @users_in = []
    @users_in = User.with_data.active.order(:identifier).where("identifier IN (#{in_ids.map { |d| d }.join(',')})") if !in_ids.empty?

    @users_in_ids = in_ids
    @users_out_ids = out_ids

    if params['detailed'] == '1'
      render 'delivery_detailed.html', :layout => 'mobile'
    else
      @users_out = @users_out.in_groups_of(3)
      @users_in = @users_in.in_groups_of(3)

      render 'delivery.html', :layout => 'mobile'
    end
  end
end
