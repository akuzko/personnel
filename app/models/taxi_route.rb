class TaxiRoute < ActiveRecord::Base
  def name
    traced
  end
end
