class HomeController < ApplicationController
  def index
    expires_in 3.hours, :public => true
  end

end
