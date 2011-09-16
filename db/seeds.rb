# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
Admin.create(:email => 'valnech@zone3000.net', :password => 'wewewewe', :approved => 1, :super_user => 1)
Department.create(:name => 'General', :has_identifier => 0)
ScheduleStatus.create(:name => 'shift_leader', :color => '008000')
ScheduleStatus.create(:name => 'New', :color => '00FF00')
ScheduleStatus.create(:name => 'Absence', :color => 'FF0000')
ScheduleStatus.create(:name => 'Sick', :color => '0000FF')
ScheduleStatus.create(:name => 'Vacation', :color => '008000')
ScheduleStatus.create(:name => 'Unpaid', :color => '993366')
