class ShiftLeaderScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :shift_leader, :class_name => "User", :foreign_key => "shift_leader_id"
  delegate :full_name, :to => :user, :prefix => true
  attr_accessible :score, :comment, :shift_date, :shift_number, :shift_leader_id
  validates_presence_of :score

  def self.search(params, admin_id)
    params[:sort_by] ||= :shift_date
    params[:sort_order] ||= "DESC"
    sort_by = {
        :shift_date => '`shift_date`',
        :score => '`score`',
        :full_name => '`profiles`.last_name'
    }

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map { |d| d.id }.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("`shift_leader_scores`.`shift_leader_id` = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("shift_date >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("shift_date <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    includes(:shift_leader => :profile).
        paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
                 :conditions => conditions.join(' and '),
                 :order => "#{sort_by[params[:sort_by].to_sym]} #{params[:sort_order]}"
  end
end
