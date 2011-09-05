class MissedShift < ActionMailer::Base
  default :from => "valnech@zone3000.net"
  layout "mail"

  def send_missed_shifts(department_name, missed_shifts, admins)
    @department_name = department_name
    @missed_shifts = missed_shifts
    @admins = admins
    mail(
      :to => admins.join(","),
      :from => "valnech@zone3000.net",
      :subject => "Missed Shifts"
    )
  end
end
