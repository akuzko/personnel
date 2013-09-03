class Admin::AddressesController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index

  end

  def show

  end

  def new
    @address = Address.new
    @address.user_id = params[:user]
    render :layout => false
  end

  def edit
    @address = Address.find params[:id]
    render :layout => false
  end

  def create
    @address = Address.new(params[:address])
    @address.primary = 1 if Address.find_all_by_user_id_and_primary(@address.user_id, 1).count == 0
    if @address.save
      Log.add(current_admin, @address, params)
      render(:update) { |p| p.call 'app.display_addresses_admin', @address.user_id, @address.id }
    else
      message = '<p>' + @address.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#address_flash'].parents(0).show
        page['#address_flash'].html message
      end
    end
  end

  def update
    @address = Address.find(params[:id])
    params[:previous_attributes] = @address.attributes
    if @address.update_attributes(params[:address])
      Log.add(current_admin, @address, params)
      render(:update) { |p| p.call 'app.display_addresses_admin', @address.user_id, @address.id }
    else
      message = '<p>' + @address.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#address_flash'].parents(0).show
        page['#address_flash'].html message
      end
    end
  end

  def destroy
    @address = Address.find(params[:id])
    Log.add(current_admin, @address, params)
    @address = Address.find_by_user_id_and_primary(@address.user_id, 1)
    Address.delete(params[:id])
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses_admin', @address.user_id, @address.id } }
    end
  end

  def make_primary
    @address = Address.find(params[:id])

    @old_primaries = Address.find_all_by_user_id_and_primary(@address.user_id, 1)
    @old_primaries.each do |addr|
      addr.update_attributes({:primary => 0})
    end
    @address.update_attributes({:primary => 1})
    Log.add(current_admin, @address, params)
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses_admin', @address.user_id, @address.id } }
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
