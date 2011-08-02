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
      if @address.save!
        render(:update){ |p| p.call 'app.display_addresses', @address.user_id, @address.id }
      else
        #error
      end
    end

  def update
    @address = Address.find(params[:id])
      if @address.update_attributes(params[:address])
        render(:update){ |p| p.call 'app.display_addresses', @address.user_id, @address.id }
      else
        #error
      end
    end

  def destroy

  end

  def make_primary
    @address = Address.find(params[:id])

    @old_primary = Address.where(:user_id => @address.user_id, :primary => 1).first
    @old_primary.update_attributes({'primary' => 0}) if @old_primary

    @address.update_attributes({'primary' => 1})
    respond_to do |format|
      format.js { render() { |p| p.call 'app.display_addresses', @address.user_id, @address.id } }
    end
  end

end
