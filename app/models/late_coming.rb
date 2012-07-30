class LateComing < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift
  validates_presence_of :description, :user_id, :shift_id
  validates_length_of :description, :minimum => 5, :message => ' - it will be hard to remember the exact reason, better write it now'
  delegate :full_name, :to => :user, :prefix => true

  def self.search(params, admin_id)
    params[:sort_by] ||= '`profiles`.last_name, `profiles`.first_name, `shifts`.shiftdate'

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("`shifts`.user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("`shifts`.shiftdate >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("`shifts`.shiftdate <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    includes(:user => :profile, :shift => [:started, :ended, :schedule_shift]).
    joins(:shift, :user => :profile).
    paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end
end
