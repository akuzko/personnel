class HomeController < ApplicationController
  def index
    redirect_to user_url()
  end

end
