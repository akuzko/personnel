class Event < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  validates_presence_of :description, :user_id, :category_id
  delegate :name, :to => :category, :prefix => true
  delegate :displayed, :to => :category, :prefix => true
  delegate :full_name, :to => :user, :prefix => true

  scope :identified, where('identifier IS NOT NULL')

  def self.search(params, page, admin_id)
    params[:sort_by] ||= :eventtime

    admin = Admin.find_by_id(admin_id)
    conditions = []
    conditions.push("`users`.department_id IN (#{admin.departments.map{|d|d.id}.join(',')})") unless admin.super_user?
    conditions.push("user_id = '" + params[:user_id] + "'") unless params[:user_id].nil? || params[:user_id] == ""
    conditions.push("eventtime >= '" + params[:date_from].to_s + "'") unless params[:date_from].nil? || params[:date_from] == "" || params[:date_from_check].nil?
    conditions.push("eventtime <= '" + params[:date_to].to_s + "'") unless params[:date_to].nil? || params[:date_to] == "" || params[:date_to_check].nil?

    paginate :per_page => 15, :page => page,
             :conditions => conditions.join(' and '),
             :order => params[:sort_by]
  end

  def self.login(user_id, time, ip)
    @general_department = Department.find_or_create_by_name('General')
    @category = Category.find_or_create_by_name_and_department_id('Login', @general_department.id)
    @event = Event.create(:user_id => user_id, :category_id => @category.id, :eventtime => time, :ip_address => ip2int(ip), :description => '-')
    @event.save
    @event.id
  end

  def self.logout(user_id, time, ip)
    @general_department = Department.find_or_create_by_name('General')
    @category = Category.find_or_create_by_name_and_department_id('Logout', @general_department.id)
    @event = Event.create(:user_id => user_id, :category_id => @category.id, :eventtime => time, :ip_address => ip2int(ip), :description => '-')
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
