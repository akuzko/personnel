class Shift < ActiveRecord::Base
  belongs_to :user
  has_one :late_coming, :dependent => :destroy
  validates_presence_of :number, :user_id
  delegate :full_name, :to => :user, :prefix => true

  def self.search(params, admin_id)
    params[:sort_by] ||= :shiftdate

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("shiftdate >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("shiftdate <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def starttime
    @event = Event.find_by_id(self.start_event)
    @event.nil? ? '' : @event.eventtime
  end

  def endtime
    @event = Event.find_by_id(self.end_event)
    @event.nil? ? '' : @event.eventtime
  end

  def start_ip
    @event = Event.find_by_id(self.start_event)
    @event.nil? ? '' : Event.int2ip(@event.ip_address)
  end

  def end_ip
    @event = Event.find_by_id(self.end_event)
    @event.nil? ? '' : Event.int2ip(@event.ip_address)
  end

  def worked_min
    return '' if self.endtime == '' || self.starttime == ''
    ((self.endtime - self.starttime) / 1.minute).round
  end

  def schedule_shift
    ScheduleTemplate.find_by_department_id_and_year_and_month(User.find(self.user_id).department_id, self.shiftdate.year, self.shiftdate.month).schedule_shifts.find_by_number(self.number)
  end

  def is_late
    can_late_minutes = self.schedule_shift.start == 0 ? 10 : 5
    (self.starttime - (self.shiftdate + self.schedule_shift.start.hour))/ 1.minutes > can_late_minutes
  end

  def is_over
    (self.shiftdate + self.schedule_shift.end.hour) < DateTime.current
  end
end
