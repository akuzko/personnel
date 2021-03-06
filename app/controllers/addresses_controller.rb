class AddressesController < ApplicationController
  before_filter :authenticate_user!

  def index

  end

  def show

  end

  def new
    @address = Address.new
    @address.user_id = current_user.id
    render :layout => false
  end

  def edit
    @address = Address.find params[:id]
    render :layout => false
  end

  def create
    @address = Address.new(params[:address])
    @address.user_id = current_user.id
    @address.primary = 1 if Address.find_all_by_user_id_and_primary(current_user.id, 1).count == 0
    if @address.save
      @address.get_map
      Log.add(current_user, @address, params)
      render(:update){ |p| p.call 'app.display_addresses', @address.id }
    else
      message = '<p>' + @address.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#address_flash'].parents(0).show
        page['#address_flash'].html message
      end
    end
  end

  def update
    @address = Address.find_by_id_and_user_id(params[:id], current_user.id)
    params[:previous_attributes] = @address.attributes
    if @address.update_attributes(params[:address])
      @address.get_map
      Log.add(current_user, @address, params)
      render(:update) do  |p|
        p.call 'app.display_addresses', @address.id
        p.call 'app.display_dialog', '/user/notify_address' if @address.primary and current_user.has_identifier?
      end
    else
      message = '<p>' + @address.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#address_flash'].parents(0).show
        page['#address_flash'].html message
      end
    end
  end

  def destroy
    @address = Address.find_by_id_and_user_id(params[:id], current_user.id)
    @address_primary = Address.find_by_user_id_and_primary(@address.user_id, 1)
    Log.add(current_user, @address, params)
    Address.delete(@address)
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses', @address_primary.id } }
    end
  end

  def make_primary
    @address = Address.find_by_id_and_user_id(params[:id], current_user.id)

    @old_primaries = Address.find_all_by_user_id_and_primary(current_user.id, 1)
    @old_primaries.each do |addr|
      addr.update_attributes({'primary' => 0})
    end

    @address.update_attributes({'primary' => 1})
    Log.add(current_user, @address, params)
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses', @address.id } }
    end
  end

  def map
    @address = Address.find_by_id(params[:id])
    if @address.lat.blank? or @address.lng.blank?
      @address.get_map
    end
    render layout: false
  end

  def update_map
    @address = Address.find_by_id(params[:id])
    return false unless current_user.extended_permissions_by_section('edit_map').include?(@address.user.department_id)
    Address.record_timestamps= false
    @address.assign_attributes(lat: params[:lat], lng: params[:lng])
    @address.save(validate: false)
    Address.record_timestamps= true
    render(:update) do |page|
      page['.flash'].html "<div class='message notice'><p>Map has been updated</p></div>"
      page["#overlay"].dialog("close")
    end
  end

end
