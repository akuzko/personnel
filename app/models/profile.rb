class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :logs, :as => :subject
  validates_presence_of :last_name, :first_name, :on => :update
  validates_presence_of :t_shirt_size, :if => :has_t_shirt?, :on => :update
  before_validation :fix_nils

  def self.size_selection
    ['S men', 'M men', 'L men', 'XL men', 'XXL men', 'XXXL men','XS women','S women', 'M women', 'L women', 'XL women', 'XXL women'].map do |d|
      [d, d]
    end
  end

  def self.level_selection
    ['Newbee', 'Padawan', 'Guru', 'Jedi', 'Neutral'].map do |d|
      [d, d]
    end
  end

  def has_t_shirt?
    false if user.department_id.nil?
    Department.find(user.department_id).has_t_shirt? if user.department_id
  end

  def has_levels?
    false if user.department_id.nil?
    Department.find(user.department_id).has_levels? if user.department_id
  end

  def fix_nils
    self.level = '' if self.level.nil?
    self.t_shirt_size = '' if self.t_shirt_size.nil?
  end
end
