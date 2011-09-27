class AdminSetting < ActiveRecord::Base
  belongs_to :admin

  def self.selection
    ['per_page']
  end
end
