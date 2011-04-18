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

  delegate :birthdate, :to => :profile, :allow_nil => true
  delegate :cell1, :cell2, :to => :contact, :allow_nil => true
  delegate :name, :to => :department, :prefix => true

  scope :with_data, includes(:profile, :address, :contact)

  validates_presence_of :department_id
  validates_presence_of :identifier, :if => :has_identifier?
  validates_uniqueness_of :identifier, :scope => :department_id

  cattr_accessor :per_page
  @@per_page = 20

  def has_identifier?
    (department || Department.find(department_id)).has_identifier?
  end

  def full_name
    [profile.last_name, profile.initials] * ' ' rescue email
  end

  def full_address
    "#{address.street}, #{address.build} || #{address.porch} / #{address.nos}" if address
  end
end
