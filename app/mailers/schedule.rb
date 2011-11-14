class Schedule < ActionMailer::Base
  default :from => "valnech@zone3000.net"
  layout "mail"

  def send_invitation_to_user(user)
    @user = user
    mail(
      :to => user.email,
      :from => "Zone3000 <valnech@zone3000.net>",
      :subject => "Create your schedule"
    )
  end
end
