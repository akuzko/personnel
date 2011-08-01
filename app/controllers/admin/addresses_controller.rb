class Admin::AddressesController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin'

    def index

    end

    def show

    end

    def new
      @address = Address.new
      render :partial => 'edit'
    end

    def edit
      @address = Address.find params[:id]
      render :partial => 'edit'
    end

    def create

    end

    def update

    end

    def destroy

    end
end
