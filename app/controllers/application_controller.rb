class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_filled_profile
    @user = User.find current_user.id
    if @user.profile.first_name.nil? || @user.addresses.empty? || @user.contact.cell1.blank? || !@user.avatar.exists? || @user.contact.jabber.blank?
      redirect_to "/user"
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    request.referrer
  end
end
