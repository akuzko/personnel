class HrNotification < ActionMailer::Base
  default :from => "valnech@zone3000.net"
  layout "mail"

  def send_user_activated(user)
    @user = user
    mail(
        :to => 'hr_team@zone3000.net',
        :from => "Zone3000 <valnech@zone3000.net>",
        :subject => "New user activation"
    )
  end
end

