class Category < ActiveRecord::Base
  belongs_to :department
  validates_presence_of :name, :department_id
  delegate :name, :to => :department, :prefix => true

  def self.search(params, page)
    params[:sort_by] ||= :name

    conditions = []
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
end