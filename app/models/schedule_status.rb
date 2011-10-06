class ScheduleStatus < ActiveRecord::Base
  validates_presence_of :name, :color
  validates_uniqueness_of :name

  def self.selection
    order(:name).where('name <> ?', 'Shift Leader').all.map{ |d| [d.name, d.id] }
  end
end
