class UserAuth < ActionMailer::Base
  default :from => "valnech@zone3000.net"
  layout "mail"

  def send_user_created(user, admins)
    @user = user
    if !admins.nil?
      mail(
          :to => admins.join(","),
          :from => "Zone3000 <valnech@zone3000.net>",
          :subject => "New user signup"
      )
    end
  end
end

