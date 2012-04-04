class FiredPermissions < ActionMailer::Base
  default :from => "valnech@zone3000.net"
  layout "mail"

  def send_missed_permissions(user)

    @department_name = user.department.name
    @missed_permissions = user.permissions
    @admins = user.department.admins.map(&:email)
    @user = user
    mail(
        :to => @admins.join(","),
        :from => "Zone3000 <valnech@zone3000.net>",
        :subject => "Manage Permissions For Fired User"
    )
  end
end
