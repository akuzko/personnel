class Norm < ActiveRecord::Base
  belongs_to :user

  def self.generate(params)
    ap params
  end

  def update

  end
end