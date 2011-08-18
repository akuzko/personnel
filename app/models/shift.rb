class Shift < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :number, :user_id
  delegate :full_name, :to => :user, :prefix => true

  def self.search(params, page)
    params[:sort_by] ||= :shiftdate

    conditions = []
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("shiftdate >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("shiftdate <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => 15, :page => page,
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

  def worked_min
    return '' if self.endtime == '' || self.starttime == ''
    ((self.endtime - self.starttime) / 1.minute).round
  end
end
