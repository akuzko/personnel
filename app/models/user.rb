class User < ActiveRecord::Base
  IDENTIFIER_THRESHOLD = 50
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :identifier, :department_id

  belongs_to :department

  has_one :profile
  has_many :addresses
  has_one :contact

  after_create :create_internals

  delegate :birthdate, :to => :profile, :allow_nil => true
  delegate :cell1, :cell2, :cell3, :to => :contact, :allow_nil => true
  delegate :home_phone, :to => :contact, :allow_nil => false
  delegate :name, :to => :department, :prefix => true

  scope :with_data, includes(:profile, :addresses, :contact)
  scope :identified, where('identifier IS NOT NULL')
  scope :identifiers, order('identifier ASC').select('identifier')

  #validates_presence_of :department_id, :on => :update
  validates_presence_of :identifier, :if => :has_identifier?, :on => :update
  validates_presence_of :home_phone, :on => :update
  validates_uniqueness_of :identifier, :scope => :department_id, :if => :has_identifier?, :on => :update
  validates_confirmation_of :password

  def self.identifier_selection include_id = nil
    identifiers = identified.identifiers.map(&:identifier)
    last = identifiers.last || 1
    identifiers = ((1..last+IDENTIFIER_THRESHOLD).to_a - identifiers + [include_id]).compact.sort
    identifiers.zip identifiers
  end
  
  def has_identifier?
    (department || Department.find(department_id)).has_identifier? if department_id
  end

  def full_name
    name = [profile.last_name, profile.initials] * ' '
    name == ' ' ? email : name
  end

  def full_address
    attributes = %w(street build porch nos)
    separators = [', ', ' || ', ' / ']
    #debugger
    return nil if attributes.any?{ |a| addresses[0][a].nil? || addresses[0][a] == '' }
    attributes.map{ |a| addresses[0][a] }.zip(separators).flatten.compact.join
  end

  private

  def create_internals
    create_profile
    #create_address
    create_contact
  end
end
