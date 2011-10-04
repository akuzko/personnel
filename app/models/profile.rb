class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :logs, :as => :subject
  validates_presence_of :last_name, :first_name, :on => :update
  validates_presence_of :t_shirt_size, :if => :has_t_shirt?, :on => :update

  def self.size_selection
    ['S men', 'L men', 'XL men', 'XXL men', 'XXXL men','XS women','S women', 'L women', 'XL women', 'XXL women'].map do |d|
      [d, d]
    end
  end

  def has_t_shirt?
    false if user.department_id.nil?
    Department.find(user.department_id).has_t_shirt?
  end
end
