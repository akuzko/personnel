class UsersController < ApplicationController
  before_filter :authenticate_user!
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
        Log.add(current_user, @user, params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @user = User.find current_user.id
    flash[:alert] = "Please update your profile" if @user.profile.first_name.nil?
    flash[:alert] = "Please update your contact information" if @user.contact.cell1.nil?
    flash[:alert] = "Please add your address" if @user.addresses.empty?
    flash[:alert] = "Please upload your picture" if !@user.avatar.exists?
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
    @users = User.with_data.active.search(params)
  end

  def crop
    @user = User.find current_user.id
    if !@user.avatar.exists?
      flash[:error] = "Please upload a picture first."
      redirect_to edit_user_url(@user)
    end
  end
end
