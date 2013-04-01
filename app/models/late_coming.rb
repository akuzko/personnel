class LateComing < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift
  validates_presence_of :user_id, :shift_id, :late_type
  validates_length_of :description, :minimum => 5, :message => ' - it will be hard to remember the exact reason, better write it now', :if => :has_description?
  delegate :full_name, :to => :user, :prefix => true

  LATE_TYPES = {
      "1" => "Overslept",
      "2" => "Traffic jam",
      "3" => "Taxi coming late",
      "4" => "No available working place",
      "5" => "Mixed up the shifts",
      "6" => "Agreed with",
      "7" => "Other"
  }

  def self.search(params, admin_id)
    params[:sort_by] ||= '`profiles`.last_name, `profiles`.first_name, `shifts`.shiftdate'

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("late_type = %d" % params[:late_type].to_i) unless params[:late_type].blank?
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

  def self.type_selection
    LATE_TYPES.map do |key, value|
      [value, key]
    end
  end

  private

  def has_description?
    self.late_type > 5
  end
end
