class Department < ActiveRecord::Base
  def self.selection
    order(:name).all.map{ |d| [d.name, d.id] }
  end
end
