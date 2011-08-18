class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :home_phone, :on => :update
  validates_presence_of :cell1, :on => :update
  validates_format_of :email,
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'incorrect email format', :on => :update
end
