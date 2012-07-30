class Shift < ActiveRecord::Base
  belongs_to :user
  has_one :late_coming, :dependent => :destroy
  belongs_to :started, :class_name => "Event", :foreign_key => :start_event
  belongs_to :ended, :class_name => "Event", :foreign_key => :end_event
  belongs_to :schedule_shift
  validates_presence_of :number, :user_id
  delegate :full_name, :to => :user, :prefix => true

  def self.search(params, admin_id)
    params[:sort_by] ||= "id DESC"

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map { |d| d.id }.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("shiftdate >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("shiftdate <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    includes(:user => :profile).includes(:started, :ended, :schedule_shift).paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def starttime
    return '' unless self.started
    self.started.eventtime
    #@event = Event.find_by_id(self.start_event)
    #@event.nil? ? '' : @event.eventtime
  end

  def endtime
    return '' unless self.ended
    self.ended.eventtime
    #@event = Event.find_by_id(self.end_event)
    #@event.nil? ? '' : @event.eventtime
  end

  def start_ip
    return '' unless self.started
    Event.int2ip(self.started.ip_address)
  end

  def end_ip
    return '' unless self.ended
    Event.int2ip(self.ended.ip_address)
  end

  def workout
    (self.shift_period - self.worked_min).tap { |res| return res > 0 ? res : nil }
  end

  def worked_min
    return 0 unless self.started and self.ended
    ((self.ended.eventtime - self.started.eventtime) / 1.minute).round
  end

  def late_min
    return nil unless self.started
    if self.is_late
      ((self.started.eventtime - self.schedule_start_time)/ 1.minutes).round
    else
      nil
    end
  end

  def end_earlier
    if self.is_end_earlier
      ((self.schedule_end_time - self.endtime)/ 1.minutes).round
    else
      nil
    end
  end

  def overtime
    if self.is_overtime
      (((self.ended.eventtime - self.schedule_end_time) + (self.schedule_start_time - self.started.eventtime))/ 1.minutes).round
    else
      nil
    end
  end

  #def schedule_shift
  #  ScheduleTemplate.find_by_department_id_and_year_and_month(User.find(self.user_id).department_id, self.shiftdate.year, self.shiftdate.month).schedule_shifts.find_by_number(self.number)
  #end

  def is_late
    return false if self.schedule_start_time.blank?
    (self.starttime - self.schedule_start_time)/ 1.minutes > self.possible_minutes
  end

  def is_end_earlier
    return false if bad_shift?
    (self.schedule_end_time - self.ended.eventtime)/ 1.minutes > self.possible_minutes
  end

  def is_overtime
    return false if bad_shift?
    ((self.ended.eventtime - self.schedule_end_time) + (self.schedule_start_time - self.started.eventtime))/ 1.minutes > self.possible_minutes
  end

  def is_over
    self.schedule_end_time < DateTime.current
  end

  # Additional Methods

  def possible_minutes
    self.schedule_shift.start == 0 ? 10 : 5
  end

  def schedule_end_time
    return nil unless self.schedule_shift
    self.shiftdate + self.schedule_shift.end.hour
  end

  def schedule_start_time
    return nil unless self.schedule_shift
    self.shiftdate + self.schedule_shift.start.hour
  end

  def shift_period
    return 0 if bad_shift?
    ((self.schedule_end_time - self.schedule_start_time)/ 1.minutes).round
  end

  private

  def bad_shift?
    (self.schedule_shift.nil? or self.ended.blank? or self.schedule_end_time.blank? or self.schedule_start_time.blank? or self.started.blank?)
  end

end
