class Department < ActiveRecord::Base
  def self.selection
    all.map{ |d| [d.name, d.id] }
  end
end
