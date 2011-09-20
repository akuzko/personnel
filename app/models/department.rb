class Department < ActiveRecord::Base
  validates_presence_of :name
  has_many :admin_departments, :dependent => :destroy
  has_many :admins, :through => :admin_departments, :uniq => true
  scope :identified, where('has_identifier = 1')

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
