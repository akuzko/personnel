class Department < ActiveRecord::Base
  validates_presence_of :name
  def self.selection
    order(:name).all.map{ |d| [d.name, d.id] }
  end
end
