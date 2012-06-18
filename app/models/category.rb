class Category < ActiveRecord::Base

  has_many :department_categories, :dependent => :destroy
  has_many :departments, :through => :department_categories, :uniq => true

  #belongs_to :department

  has_many :logs, :as => :subject
  validates_presence_of :name, :display_order

  def self.search(params, admin_id)
    params[:sort_by] ||= :name
    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    [:displayed, :department_id].each do |field|
      conditions.push(field.to_s + " = '" + params[field] + "'") unless params[field].nil? || params[field] == ""
    end
    conditions.push("name LIKE '%#{params[:name]}%'") unless params[:name].nil? || params[:name] == ""
    includes(:departments).includes(:department_categories).paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :joins => "LEFT OUTER JOIN department_categories ON categories.id = category_id",
             :group => "categories.id",
             :order => "#{params[:sort_by]} #{params[:sort_order]}"
  end

  def self.selection(department_id)
    if department_id == 0
      order('display_order, name').map{ |d| [d.name, d.id] }
    else
      order('display_order, name').where(:displayed => 1).where("id IN (?)", DepartmentCategory.where(:department_id => department_id).map(&:category_id)).map{ |d| [d.name, d.id] }
    end
  end

  def self.selection_by_admin(admin_id)
    admin = Admin.find_by_id(admin_id)
    return selection(0) if admin.super_user?
    departments = admin.departments.map(&:id)
    categories = []
    order('display_order, name').map do |d|
      categories.push [d.name, d.id] if (departments & d.departments.map(&:id)).any? or %w(Login Logout).include?(d.name)
    end
    categories
  end

  def self.report_selection(department_id)
    if department_id == 0
      order(:name).find_all_by_displayed_and_reported(1, 1).map{ |d| [d.name, d.id] }
    else
      order(:name).where(:reported => 1).where(:displayed => 1).where("id IN (?)", DepartmentCategory.where(:department_id => department_id).map(&:category_id)).map{ |d| [d.name, d.id] }
    end
  end

  def self.report_selection_by_admin(admin_id)
    admin = Admin.find_by_id(admin_id)
    return report_selection(0) if admin.super_user?
    departments = admin.departments.map(&:id)
    categories = []
    where('reported=1').order(:name).map do |d|
      categories.push [d.name, d.id] if (departments & d.departments.map(&:id)).any?
    end
    categories
  end
end