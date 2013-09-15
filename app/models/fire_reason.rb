class FireReason < ActiveRecord::Base
  validates_presence_of :name

  has_many :users, dependent: :nullify

  def self.selection
    order(:name).all.map do |d|
      [d.name, d.id]
    end
  end
end
