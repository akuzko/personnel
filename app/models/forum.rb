class Forum < ActiveRecord::Base
  establish_connection "smf_forum"
  self.abstract_class = true
end