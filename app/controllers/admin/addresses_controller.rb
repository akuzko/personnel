class Admin::AddressesController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin'

    def index

    end

    def show

    end

    def new
      @address = Address.new
    end

    def edit
      @address = Address.find params[:id]
      render :layout => false
    end

    def create

    end

    def update
    @address = Address.find(params[:id])
     #debugger
      if @address.update_attributes(params[:address])
        render(:update){ |p| p.call 'app.display_addresses', @address.user_id, @address.id }
      else
        respond_to do |format|
          format.html { render :edit }
          format.xml  { render :xml => @address.errors, :status => :unprocessable_entity }
          format.json {render :json => {:message => 'not ok'}}
        end
      end
    end

    def destroy

    end
end
