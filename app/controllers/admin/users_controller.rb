class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'
  
  def index
    @users = User.with_data.order('id DESC').paginate :page => params[:page], :per_page => 15
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
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
    @suer = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @user.department_id = params[:user][:department_id] # WTF?!
    @user.identifier = params[:user][:identifier] # also WTF?!

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
    params[:user].delete(:password) if params[:user][:password].empty?

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to([:admin, @user], :notice => 'User was successfully updated.') }
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
      format.html { redirect_to(admin_users_url) }
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
    data.update_attributes(params[params[:data]])

    render(:update){ |p| p.call 'app.reload' }
  end

end
