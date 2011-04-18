class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  belongs_to :department

  has_one :profile
  has_one :address
  has_one :contact

  after_create :create_internals

  delegate :birthdate, :to => :profile, :allow_nil => true
  delegate :cell1, :cell2, :to => :contact, :allow_nil => true
  delegate :name, :to => :department, :prefix => true

  scope :with_data, includes(:profile, :address, :contact)
  scope :identified, where('identifier IS NOT NULL')

  validates_presence_of :department_id
  validates_presence_of :identifier, :if => :has_identifier?
  validates_uniqueness_of :identifier, :scope => :department_id, :if => :has_identifier?
  
  def has_identifier?
    (department || Department.find(department_id)).has_identifier?
  end

  def full_name
    name = [profile.last_name, profile.initials] * ' '
    name == ' ' ? email : name
  end

  def full_address
    attributes = %w(street build porch nos)
    separators = [', ', ' || ', ' / ']
    return nil if attributes.any?{ |a| address[a].nil? || address[a] == '' }
    attributes.map{ |a| address[a] }.zip(separators).flatten.compact.join
  end

  private

  def create_internals
    create_profile
    create_address
    create_contact
  end
end
