class UsersController < ApplicationController
  before_filter :authenticate_user!
  layout 'user'

  def index
    @user = User.find(1)
  end

  def show
  end

end
