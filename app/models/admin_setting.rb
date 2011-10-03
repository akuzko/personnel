class AdminSetting < ActiveRecord::Base
  belongs_to :admin

  def self.selection
    [['per_page', 'Number of items per page']]
  end
end
