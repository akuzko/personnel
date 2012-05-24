class SelfScore < ActiveRecord::Base
  belongs_to :user
  delegate :full_name, :to => :user, :prefix => true
  attr_accessible :score, :comment, :score_date, :selection
  validates_presence_of :score, :comment

  def self.selection
    (1..5).each do |d|
      [d, d]
    end
  end

  def self.search(params, admin_id)
    params[:sort_by] ||= "score_date DESC"

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("score_date >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("score_date <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def self.search_grouped(params, admin_id)
    params[:sort_by] ||= "score_date DESC"

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("score_date >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("score_date <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    select("self_scores.score_date, self_scores.comment, self_scores.user_id, avg(score) as avg_score").paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by],
             :group => '`users`.`id`'
  end
end
