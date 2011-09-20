class Profile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :last_name, :first_name, :t_short_size, :on => :update

  def self.size_selection
    ['XS','S', 'L', 'XL', 'XXL', 'XXXL'].map do |d|
      [d, d]
    end
  end
end
