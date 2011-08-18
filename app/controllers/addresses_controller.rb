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
      if @address.update_attributes(params[:address])
        render(:update){ |p| p.call 'app.display_addresses', @address.id }
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
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses', @address.id } }
    end
  end

end
