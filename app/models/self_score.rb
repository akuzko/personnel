class SelfScore < ActiveRecord::Base
  belongs_to :user
  attr_accessible :score, :comment, :score_date, :selection
  validates_presence_of :score, :comment

  def self.selection
    (1..5).each do |d|
      [d, d]
    end
  end
end
