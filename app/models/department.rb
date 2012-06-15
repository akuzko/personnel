class Department < ActiveRecord::Base
  validates_presence_of :name

  has_many :admin_departments, :dependent => :destroy
  has_many :admins, :through => :admin_departments, :uniq => true

  has_many :department_permissions, :dependent => :destroy
  has_many :permissions, :through => :department_permissions, :uniq => true

  has_many :department_categories, :dependent => :destroy
  has_many :categories, :through => :department_categories, :uniq => true

  has_many :logs, :as => :subject

  scope :identified, where('has_identifier = 1')

  def self.search(params, admin_id)
    params[:sort_by] ||= :name
    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => "#{params[:sort_by]} #{params[:sort_order]}"
  end

  def self.selection
    order(:name).all.map do |d|
      [d.name, d.id]
    end
  end

  def self.selection_by_admin(admin_id)
    admin = Admin.find_by_id(admin_id)
    return selection if admin.super_user?
    departments = admin.departments.map(&:id)
    admin.departments.order(:name).all.map do |d|
      if departments.include?(d.id)
        [d.name, d.id]
      end
    end
  end
end
