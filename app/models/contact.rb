class Contact < ActiveRecord::Base
  belongs_to :user
  has_many :logs, :as => :subject
  validates_presence_of :home_phone, :on => :update
  validates_presence_of :cell1, :on => :update
  validates_presence_of :jabber, :on => :update
  validates_numericality_of :cell1, :home_phone, :on => :update
  validates_format_of :email,
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'incorrect email format', :on => :update

  before_validation :replace_na_home_phone, :on => :update

  private

  def replace_na_home_phone
    self.home_phone = 0 if self.home_phone == 'n/a'
    self.jabber = 0 if self.jabber == 'n/a'
    if cell1 and (cell1_match = cell1.gsub(/\D/, "").match(/(\d{9})$/))
      self.cell1 = "+380"+cell1_match[1]
    end
    if cell2 and (cell2_match = cell2.gsub(/\D/, "").match(/(\d{9})$/))
      self.cell2 = "+380"+cell2_match[1]
    else
      self.cell2 = nil
    end
    if cell3 and (cell3_match = cell3.gsub(/\D/, "").match(/(\d{9})$/))
      self.cell3 = "+380"+cell3_match[1]
    else
      self.cell3 = nil
    end
  end
end
