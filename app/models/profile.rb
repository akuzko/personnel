class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :logs, :as => :subject
  validates_presence_of :last_name, :first_name, :on => :update
  validates_presence_of :t_short_size, :if => :has_t_short?, :on => :update

  def self.size_selection
    ['XS men','S men', 'L men', 'XL men', 'XXL men', 'XXXL men','XS women','S women', 'L women', 'XL women', 'XXL women', 'XXXL women'].map do |d|
      [d, d]
    end
  end

  def has_t_short?
    false if user.department_id.nil?
    Department.find(user.department_id).has_t_short?
  end
end
