class Event < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  belongs_to :shift
  validates_presence_of :description, :user_id, :category_id
  delegate :name, :to => :category, :prefix => true
  delegate :displayed, :to => :category, :prefix => true
  delegate :full_name, :to => :user, :prefix => true

  scope :identified, where('identifier IS NOT NULL')

  def self.search(params, admin_id)
    params[:sort_by] ||= "eventtime DESC"

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("`users`.department_id = '" + params[:department_id] + "'") unless params[:department_id].nil? || params[:department_id] == ""
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("eventtime >= '" + Time.zone.parse(params[:date_from]).getutc.to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("eventtime <= '" + Time.zone.parse(params[:date_to]).getutc.to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => [params[:per_page].to_i, 5].max, :page => params[:page],
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def self.processed_total(params, user_id, by_admin)
    model_query = Event.select('categories.name, COUNT(events.id) as total')
    model_query = model_query.where('categories.reported = 1')
    model_query = model_query.joins('INNER JOIN categories ON events.category_id = categories.id')
    if by_admin
      admin = Admin.find_by_id(user_id)
      model_query = model_query.joins('INNER JOIN department_categories ON department_categories.category_id = categories.id')
      model_query = model_query.where("department_categories.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    else
      model_query = model_query.where('user_id = ?', user_id)
    end
    model_query = model_query.where("eventtime >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == ""
    model_query = model_query.where("eventtime <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == ""
    model_query = model_query.group('categories.name')
    model_query = model_query.order('categories.name')
    model_query.all
  end

  def self.processed_by_person(params, admin_id)
    model_query = Event.select('CONCAT(profiles.last_name," ",profiles.first_name) as username, categories.name, COUNT(events.id) as total')
    model_query = model_query.where('categories.reported = 1')
    model_query = model_query.joins('INNER JOIN categories ON events.category_id = categories.id')
    model_query = model_query.joins('INNER JOIN users ON events.user_id = users.id')
    model_query = model_query.joins('INNER JOIN profiles ON profiles.user_id = users.id')
    model_query = model_query.where("events.user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    begin
      model_query = model_query.joins('INNER JOIN department_categories ON department_categories.category_id = categories.id')
      model_query = model_query.where("department_categories.department_id = '" + params[:department_id] + "'")
    end unless params[:department_id].nil? || params[:department_id] == ""
    if admin_id != 0
      admin = Admin.find_by_id(admin_id)
      model_query = model_query.where("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    end
    model_query = model_query.where("events.category_id IN (#{params[:categories].map{|d|d}.join(',')})") unless params[:categories].nil? || params[:categories].empty?
    model_query = model_query.where("eventtime >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == ""
    model_query = model_query.where("eventtime <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == ""
    model_query = model_query.group('categories.name, username')
    model_query = model_query.order('username, categories.name')
    model_query.all
  end

  def self.processed_by_day_of_week(params, user_id, by_admin)
    model_query = Event.select('DAYOFWEEK(eventtime) as weekday, categories.name, COUNT(events.id) as total')
    model_query = model_query.where('categories.reported = 1')
    model_query = model_query.joins('INNER JOIN categories ON events.category_id = categories.id')
    if by_admin
      admin = Admin.find_by_id(user_id)
      model_query = model_query.joins('INNER JOIN department_categories ON department_categories.category_id = categories.id')
      model_query = model_query.where("department_categories.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    else
      model_query = model_query.where('user_id = ?', user_id)
    end
    model_query = model_query.where("eventtime >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == ""
    model_query = model_query.where("eventtime <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == ""
    model_query = model_query.group('weekday, categories.name')
    model_query = model_query.order('weekday, categories.name')
    model_query.all
  end

  def self.login(user_id, time, ip, shift_id)
    @general_department = Department.find_or_create_by_name('General')
    @category = Category.find_or_create_by_name('Login')
    @event = Event.create(:user_id => user_id, :shift_id => shift_id, :category_id => @category.id, :eventtime => time, :ip_address => ip2int(ip), :description => '-')
    @event.save
    @event.id
  end

  def self.logout(user_id, time, ip, shift_id)
    @general_department = Department.find_or_create_by_name('General')
    @category = Category.find_or_create_by_name('Logout')
    @event = Event.create(:user_id => user_id, :shift_id => shift_id, :category_id => @category.id, :eventtime => time, :ip_address => ip2int(ip), :description => '-')
    @event.save
    @event.id
  end


  # Converts an IP string to integer
  def self.ip2int(ip)
    return 0 unless ip =~ /\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/

    v = ip.split('.').collect { |i| i.to_i }
    (v[0] << 24) | (v[1] << 16) | (v[2] << 8 ) | (v[3])
  end

  # Converts an integer to IP string... could be prettier
  def self.int2ip(int)
    tmp = int.to_i
    parts = []

    3.times do ||
      tmp = tmp / 256.0
      parts << (256 * (tmp - tmp.to_i)).to_i
    end

    parts << tmp.to_i
    parts.reverse.join('.')
  end

end
