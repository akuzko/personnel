class DepartmentPermission < ActiveRecord::Base
  belongs_to :permission
  belongs_to :department
end
