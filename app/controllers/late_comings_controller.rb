class LateComingsController < ApplicationController
  before_filter :authenticate_user!
  layout 'user'

  def index
    params[:date_from] = (Date.current - 1.month).to_formatted_s(:date_only) if !params[:date_from]
    params[:date_to] = (Date.current + 1.day).to_formatted_s(:date_only) if !params[:date_to]
    @late_comings = LateComing.order('created_at DESC').where('created_at >=?', params[:date_from]).where('created_at <=?', params[:date_to]).where(:user_id => current_user.id).paginate :page => params[:page], :order => 'created_at DESC'
    #@late_comings = LateComing.joins('JOIN users ON late_comings.user_id = users.id').joins('JOIN profiles ON profiles.user_id = users.id').joins('JOIN shifts ON late_comings.shift_id = shifts.id').search(params)

  end

end
