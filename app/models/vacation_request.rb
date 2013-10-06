class VacationRequest < ActiveRecord::Base
  belongs_to :user

  STATUS = {
      0 => 'New',
      1 => 'Approved',
      2 => 'Declined'
  }

  validates_presence_of :started, :ended

  def self.selection
    STATUS.map{|k, v| [v, k]}
  end
end
