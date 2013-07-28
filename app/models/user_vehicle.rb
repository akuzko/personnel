class UserVehicle < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :vehicle_type, :brand, :reg_number

  VEHICLE_TYPES = ['Car', 'Bike']

  def self.selection
    res = []
    VEHICLE_TYPES.each_with_index do |type, index|
      res <<[type, index]
    end
    res
  end

  def type
    VEHICLE_TYPES[vehicle_type] || 'undefined'
  end
end
