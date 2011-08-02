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
end
