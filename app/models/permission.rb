class Permission < ActiveRecord::Base
  has_many :department_permissions, :dependent => :destroy
  has_many :departments, :through => :department_permissions, :uniq => true

  has_many :user_permissions, :dependent => :destroy
  has_many :users, :through => :user_permissions, :uniq => true

  has_many :logs, :as => :subject

  validates_presence_of :name

  def self.selection
    order(:name).all.map do |d|
      [d.name, d.id]
    end
  end

  def self.in_columns
    arr = order(:name).all
    count_el_in_col = arr.length / 3
    cols = arr.length / count_el_in_col
    ap count_el_in_col
    ap cols
    arr.each_slice(count_el_in_col).to_a
  end

end
