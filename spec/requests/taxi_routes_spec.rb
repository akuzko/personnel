require 'spec_helper'

describe "TaxiRoutes" do
  describe "GET /taxi_routes" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get taxi_routes_path
      response.status.should be(200)
    end
  end
end
