class AdminDepartment < ActiveRecord::Base
  belongs_to :admin
  belongs_to :department
end
