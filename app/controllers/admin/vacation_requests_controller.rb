class Admin::VacationRequestsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    params[:status] ||= 0
    @vacation_requests = VacationRequest.joins(:user)
    @vacation_requests = @vacation_requests.where("`users`.department_id IN (#{current_admin.departments.map{|d|d.id}.join(',')})") unless current_admin.super_user?
    @vacation_requests = @vacation_requests.where("`users`.department_id = ?",  params[:department_id].to_i) unless params[:department_id].blank?
    @vacation_requests = @vacation_requests.where(user_id: params[:user_id].to_i) unless params[:user_id].blank?
    @vacation_requests = @vacation_requests.where(status: params[:status].to_i) unless params[:status].blank?
    @vacation_requests = @vacation_requests.paginate :per_page => 10, :page => params[:page], :order => "vacation_requests.created_at DESC"
  end

  def approve
    @vacation_request = VacationRequest.find_by_id params[:id]
    @vacation_request.update_attributes(status: 1)
    ActionMailer::Base.mail(:from => current_admin.email, :to => @vacation_request.user.email, :subject => "Your vacation request has been approved", :body => "Your vacation request has been approved").deliver
    redirect_to admin_vacation_requests_path
  end

  def decline
    @vacation_request = VacationRequest.find_by_id params[:id]
    @vacation_request.update_attributes(status: 2)
    ActionMailer::Base.mail(:from => current_admin.email, :to => @vacation_request.user.email, :subject => "Your vacation request has been declined", :body => "Your vacation request has been declined").deliver
    redirect_to admin_vacation_requests_path
  end

end
