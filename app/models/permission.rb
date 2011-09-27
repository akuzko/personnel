class Permission < ActiveRecord::Base
  has_many :department_permissions, :dependent => :destroy
  has_many :departments, :through => :department_permissions, :uniq => true

  has_many :user_permissions, :dependent => :destroy
  has_many :users, :through => :user_permissions, :uniq => true

  validates_presence_of :name

  def self.selection
    order(:name).all.map do |d|
      [d.name, d.id]
    end
  end

end
