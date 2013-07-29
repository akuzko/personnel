class UserVehiclesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user
    render :layout => false
  end

  def show

  end

  def new
    @vehicle = UserVehicle.new
    @vehicle.user_id = current_user.id
    render :layout => false
  end

  def edit
    @vehicle = UserVehicle.find params[:id]
    render :layout => false
  end

  def create
    @vehicle = UserVehicle.new(params[:user_vehicle])
    @vehicle.user_id = current_user.id
    if @vehicle.save
      Log.add(current_user, @vehicle, params)
      render(:update) do |p|
        p["#overlay"].dialog("close")
        p.call 'app.display_vehicles'
      end
    else
      message = '<p>' + @vehicle.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#vehicle_flash'].parents(0).show
        page['#vehicle_flash'].html message
      end
    end
  end

  def update
    @vehicle = UserVehicle.find_by_id_and_user_id(params[:id], current_user.id)
    params[:previous_attributes] = @vehicle.attributes
    if @vehicle.update_attributes(params[:user_vehicle])
      ap @vehicle
      ap params
      Log.add(current_user, @vehicle, params)
      render(:update) do  |p|
        p["#overlay"].dialog("close")
        p.call 'app.display_vehicles'
      end
    else
      message = '<p>' + @vehicle.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#vehicle_flash'].parents(0).show
        page['#vehicle_flash'].html message
      end
    end
  end

  def destroy
    @vehicle = UserVehicle.find_by_id_and_user_id(params[:id], current_user.id)
    Log.add(current_user, @vehicle, params)
    @vehicle.destroy
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_vehicles'} }
    end
  end

end
