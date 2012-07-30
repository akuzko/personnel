class AddScheduleShiftToShifts < ActiveRecord::Migration
  def change
    #change_table :shifts do |t|
    #  t.references :schedule_shift
    #end
    #add_index :shifts, :schedule_shift_id
    Shift.all.each do |shift|
      shift.update_attribute(:schedule_shift, ScheduleTemplate.find_by_department_id_and_year_and_month(User.find(shift.user_id).department_id, shift.shiftdate.year, shift.shiftdate.month).schedule_shifts.find_by_number(shift.number))
    end
  end
end
