class Admin::BirthdaysController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    params[:months] ||= 1

    @users = User.active.includes(:profile, :department).where("profiles.birthdate IS NOT NULL")
    @users = @users.where("department_id = ?", params[:department_id]) unless params[:department_id].blank?
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
