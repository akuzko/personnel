require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe TaxiRoutesController do

  # This should return the minimal set of attributes required to create a valid
  # TaxiRoute. As you add validations to TaxiRoute, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TaxiRoutesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all taxi_routes as @taxi_routes" do
      taxi_route = TaxiRoute.create! valid_attributes
      get :index, {}, valid_session
      assigns(:taxi_routes).should eq([taxi_route])
    end
  end

  describe "GET show" do
    it "assigns the requested taxi_route as @taxi_route" do
      taxi_route = TaxiRoute.create! valid_attributes
      get :show, {:id => taxi_route.to_param}, valid_session
      assigns(:taxi_route).should eq(taxi_route)
    end
  end

  describe "GET new" do
    it "assigns a new taxi_route as @taxi_route" do
      get :new, {}, valid_session
      assigns(:taxi_route).should be_a_new(TaxiRoute)
    end
  end

  describe "GET edit" do
    it "assigns the requested taxi_route as @taxi_route" do
      taxi_route = TaxiRoute.create! valid_attributes
      get :edit, {:id => taxi_route.to_param}, valid_session
      assigns(:taxi_route).should eq(taxi_route)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TaxiRoute" do
        expect {
          post :create, {:taxi_route => valid_attributes}, valid_session
        }.to change(TaxiRoute, :count).by(1)
      end

      it "assigns a newly created taxi_route as @taxi_route" do
        post :create, {:taxi_route => valid_attributes}, valid_session
        assigns(:taxi_route).should be_a(TaxiRoute)
        assigns(:taxi_route).should be_persisted
      end

      it "redirects to the created taxi_route" do
        post :create, {:taxi_route => valid_attributes}, valid_session
        response.should redirect_to(TaxiRoute.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved taxi_route as @taxi_route" do
        # Trigger the behavior that occurs when invalid params are submitted
        TaxiRoute.any_instance.stub(:save).and_return(false)
        post :create, {:taxi_route => {}}, valid_session
        assigns(:taxi_route).should be_a_new(TaxiRoute)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TaxiRoute.any_instance.stub(:save).and_return(false)
        post :create, {:taxi_route => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested taxi_route" do
        taxi_route = TaxiRoute.create! valid_attributes
        # Assuming there are no other taxi_routes in the database, this
        # specifies that the TaxiRoute created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TaxiRoute.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => taxi_route.to_param, :taxi_route => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested taxi_route as @taxi_route" do
        taxi_route = TaxiRoute.create! valid_attributes
        put :update, {:id => taxi_route.to_param, :taxi_route => valid_attributes}, valid_session
        assigns(:taxi_route).should eq(taxi_route)
      end

      it "redirects to the taxi_route" do
        taxi_route = TaxiRoute.create! valid_attributes
        put :update, {:id => taxi_route.to_param, :taxi_route => valid_attributes}, valid_session
        response.should redirect_to(taxi_route)
      end
    end

    describe "with invalid params" do
      it "assigns the taxi_route as @taxi_route" do
        taxi_route = TaxiRoute.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TaxiRoute.any_instance.stub(:save).and_return(false)
        put :update, {:id => taxi_route.to_param, :taxi_route => {}}, valid_session
        assigns(:taxi_route).should eq(taxi_route)
      end

      it "re-renders the 'edit' template" do
        taxi_route = TaxiRoute.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TaxiRoute.any_instance.stub(:save).and_return(false)
        put :update, {:id => taxi_route.to_param, :taxi_route => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested taxi_route" do
      taxi_route = TaxiRoute.create! valid_attributes
      expect {
        delete :destroy, {:id => taxi_route.to_param}, valid_session
      }.to change(TaxiRoute, :count).by(-1)
    end

    it "redirects to the taxi_routes list" do
      taxi_route = TaxiRoute.create! valid_attributes
      delete :destroy, {:id => taxi_route.to_param}, valid_session
      response.should redirect_to(taxi_routes_url)
    end
  end

end
