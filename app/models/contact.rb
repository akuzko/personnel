class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :home_phone, :on => :update
end
