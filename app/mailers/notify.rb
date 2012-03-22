class Notify < ActionMailer::Base
  layout "mail"

  def address_changed(user)
    @user = user
    mail(
        :to => "girls@zone3000.net",
        :from => "#{user.full_name} <#{user.email}>",
        :subject => "My primary address has been changed"
    )
  end
end