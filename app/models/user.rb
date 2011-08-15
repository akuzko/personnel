class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :identifier, :department_id, :active

  belongs_to :department

  has_one :profile, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  has_one :contact, :dependent => :destroy
  has_many :schedule_cells, :dependent => :destroy

  after_create :create_internals

  delegate :birthdate, :to => :profile, :allow_nil => true
  delegate :cell1, :cell2, :cell3, :to => :contact, :allow_nil => true
  delegate :home_phone, :to => :contact, :allow_nil => false
  delegate :name, :to => :department, :prefix => true

  scope :with_data, includes(:profile, :addresses, :contact)
  scope :identified, where('identifier IS NOT NULL')
  scope :active, where('active = 1')
  #scope :identifiers, order('identifier ASC').select('identifier')

  validates_presence_of :identifier, :if => :has_identifier?, :on => :update
  validates_uniqueness_of :identifier, :scope => :active, :if => :has_identifier?, :on => :update
  validates_confirmation_of :password
  validates_format_of :email,
    :with => /\A([^@\s]+)@zone3000\.net\Z/i,
    :message => 'Only Zone3000 local email is acceptable'

  before_validation :clean_unused_identifier

  def has_identifier?
    (department || Department.find(department_id)).has_identifier? if department_id
  end

  def full_name
    name = [profile.last_name, profile.initials] * ' '
    name == ' ' ? email : name
  end

  def full_address
    @address = addresses.order('addresses.primary DESC').first
    return '' if @address.nil?
    attributes = %w(street build porch nos)
    separators = [', ', ' || ', ' / ']
    return nil if attributes.any?{ |a| @address[a].nil? || @address[a] == '' }
    attributes.map{ |a| @address[a] }.zip(separators).flatten.compact.join
  end

  def full_address_admin
    @address = addresses.order('addresses.primary DESC').first
    return '' if @address.nil?
    attributes = %w(street build porch nos room)
    separators = [', ', ' || ', ' / ', ', app.']
    return nil if attributes.any?{ |a| @address[a].nil? || @address[a] == '' }
    attributes.map{ |a| @address[a] }.zip(separators).flatten.compact.join
  end

  private

  def create_internals
    create_profile
    create_contact
  end

  def self.search(params, page)
    conditions = []
    [:active, :department_id, :identifier].each do |field|
      conditions.push(field.to_s + " = '" + params[field] + "'") unless params[field].nil? || params[field] == ""
    end
    conditions.push("`profiles`.last_name LIKE '%#{params[:full_name]}%'") unless params[:full_name].nil? || params[:full_name] == ""
    paginate :per_page => 15, :page => page,
             :conditions => conditions.join(' and '),
             :order => '`profiles`.last_name'
  end

  def clean_unused_identifier
    self.identifier = "" unless Department.find(self.department_id).has_identifier?
  end

  def self.selection(department_id)
    order(:identifier).find_all_by_department_id(department_id).map{ |d| [d.identifier.to_s+ ' '+d.full_name, d.identifier] }
  end
end
