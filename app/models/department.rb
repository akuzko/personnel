class Department < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 25

  def self.selection
    all.map{ |d| [d.name, d.id] }
  end
end
