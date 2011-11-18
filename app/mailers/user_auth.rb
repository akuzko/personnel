class UserAuth < ActionMailer::Base
  default :from => "f1n@zone3000.net"
  layout "mail"

  def send_user_created(user, admins)
    @user = user
    admins.each do |mail|
      mail(
        :to => mail,
        :from => "Zone3000 <valnech@zone3000.net>",
        :subject => "New user signup"
      )
    end
  end
end
