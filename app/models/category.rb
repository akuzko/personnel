class Category < ActiveRecord::Base
  belongs_to :department
  validates_presence_of :name, :department_id
  delegate :name, :to => :department, :prefix => true

  def self.search(params, page, admin_id)
    params[:sort_by] ||= :name
    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    [:displayed, :department_id].each do |field|
      conditions.push(field.to_s + " = '" + params[field] + "'") unless params[field].nil? || params[field] == ""
    end
    conditions.push("name LIKE '%#{params[:name]}%'") unless params[:name].nil? || params[:name] == ""
    paginate :per_page => 15, :page => page,
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def self.selection(department_id)
    if department_id == 0
      order(:name).map{ |d| [d.name, d.id] }
    else
      order(:name).find_all_by_department_id_and_displayed(department_id, 1).map{ |d| [d.name, d.id] }
    end
  end

  def self.selection_by_admin(admin_id)
    admin = Admin.find_by_id(admin_id)
    return selection(0) if admin.super_user?
    departments = admin.departments.map{|d|d.id}
    categories = []
    order(:name).map do |d|
      categories.push [d.name, d.id] if departments.include?(d.department_id)
    end
    categories
  end

  def self.report_selection(department_id)
    if department_id == 0
      order(:name).find_all_by_displayed_and_reported(1, 1).map{ |d| [d.name, d.id] }
    else
      order(:name).find_all_by_department_id_and_displayed_and_reported(department_id, 1, 1).map{ |d| [d.name, d.id] }
    end
  end

  def self.report_selection_by_admin(admin_id)
    admin = Admin.find_by_id(admin_id)
    return report_selection(0) if admin.super_user?
    departments = admin.departments.map{|d|d.id}
    categories = []
    where('reported=1').order(:name).map do |d|
      categories.push [d.name, d.id] if departments.include?(d.department_id)
    end
    categories
  end
end