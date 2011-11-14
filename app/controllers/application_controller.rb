class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_filled_profile
    @user = User.find current_user.id
    if !@user.avatar.exists? || @user.profile.first_name.nil? || @user.addresses.empty? || @user.contact.cell1.nil?
      redirect_to "/user"
    end
  end
end
