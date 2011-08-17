class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'
  
  def index
    #@users = User.with_data.order('id DESC').paginate :page => params[:page], :per_page => 15
    @users = User.with_data.search(params, params[:page])
  end

  def delivery
    @users = User.identified.with_data.order('identifier ASC').paginate :page => params[:page], :per_page => 15

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    @user = User.with_data.find(params[:id])

    respond_to do |format|
      format.html{ render :partial => 'show' if request.xhr? }
      format.xml{ render :xml => @user }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
    @back_url = request.env["HTTP_REFERER"]
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to([:admin, @user], :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @back_url = params[:user][:back_url]
    params[:user].delete(:back_url)
    if params[:user][:password].empty?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @back_url }#redirect_to(admin_user_url, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url, :notice => 'User was successfully deleted.') }
      format.xml  { head :ok }
    end
  end

  def edit_data
    user = User.find params[:id]

    render :partial => params[:data], :object => user.send(params[:data]), :locals => {:user => user}
  end

  def update_data
    user = User.find params[:id]
    data = user.send(params[:data])
    if data.update_attributes(params[params[:data]])
      render(:update){ |p| p.call 'app.reload_section_admin', params[:id],  params[:data]}
    else
      message = '<p>' + data.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#'+params[:data]+'_flash'].parents(0).show
        page['#'+params[:data]+'_flash'].html message
      end
    end
  end

  def display_addresses
    @user = User.find params[:id]
    render '_show_addresses.html', :layout => false
  end

  def display_section
    @user = User.find params[:id]
    render '_show_'+params[:section]+'.html', :layout => false
  end


end
