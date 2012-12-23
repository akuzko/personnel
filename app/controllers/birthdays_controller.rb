class BirthdaysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile
  layout 'user'

  def index
    params[:months] ||= 1
    departments = []
    departments << current_user.department_id
    departments << current_user.extended_permissions_by_section('birthdays')
    @users = User.active.includes(:profile, :department).where("profiles.birthdate IS NOT NULL").where("department_id IN (?)", departments.flatten)
    @today = []
    @result = @users.each.inject([]) do |res, user|
      date = Date.new(Date.current.year, user.profile.birthdate.month, user.profile.birthdate.day)
      date = date + 1.year if (Date.current - date).days > 0

      user.birth_day_and_month = date
      @today << user if date == Date.current
      res << user if (date - Date.current.advance(months: params[:months].to_i) < 0 and date != Date.current)
      res
    end.sort{|l, r| l.birth_day_and_month <=> r.birth_day_and_month}
  end
end
