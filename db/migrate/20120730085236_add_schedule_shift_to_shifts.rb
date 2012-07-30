class AddScheduleShiftToShifts < ActiveRecord::Migration
  def change
    change_table :shifts do |t|
      t.references :schedule_shift
    end
    add_index :shifts, :schedule_shift_id
    @templates = ScheduleTemplate.all.each.inject({}) do |res, t|
      res["#{t.department_id}_#{t.year}_#{t.month}"] = t
      res
    end
    Shift.includes(:user).all.each do |shift|
      @template = @templates["#{shift.user.department_id}_#{shift.shiftdate.year}_#{shift.shiftdate.month}"]
      next unless @template
      @schedule_shift = @template.schedule_shifts.where(:number => shift.number).first
      shift.update_attribute(:schedule_shift, @schedule_shift)
    end
  end
end
