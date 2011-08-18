class Profile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :last_name, :initials, :on => :update
end
