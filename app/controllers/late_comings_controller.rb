class LateComingsController < ApplicationController
before_filter :authenticate_user!
  layout 'user'

def index
  @late_comings = LateComing.order('created_at DESC').find_all_by_user_id(current_user.id).paginate :page => params[:page], :order => 'created_at DESC'
end

end
