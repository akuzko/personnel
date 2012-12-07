class BirthdaysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile
  layout 'user'

  def index
    departments = []
    departments << current_user.department_id
    departments << current_user.extended_permissions_by_section('birthdays')
    @users = User.includes(:profile, :department).where("profiles.birthdate IS NOT NULL").where("department_id IN (?)", departments.flatten)

    @result = @users.each do |user|
      date = DateTime.new(Date.current.year, user.profile.birthdate.month, user.profile.birthdate.day)
      date = date + 1.year if (Date.current - date).days > 0

      user.birth_day_and_month = date
    end.sort{|l, r| l.birth_day_and_month <=> r.birth_day_and_month}

  end
end
