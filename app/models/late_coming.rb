class LateComing < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift
  validates_presence_of :description, :user_id, :shift_id
  delegate :full_name, :to => :user, :prefix => true

  def self.search(params, page, admin_id)
    params[:sort_by] ||= '`shifts`.shiftdate DESC'

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("`shifts`.shiftdate >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("`shifts`.shiftdate <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => 15, :page => page,
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end
end
