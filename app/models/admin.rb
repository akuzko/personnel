class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :admin_departments, :dependent => :destroy
  has_many :departments, :through => :admin_departments, :uniq => true
  has_many :logs_entered, :class_name => 'Log', :as => :author
  has_many :logs, :as => :subject
  has_many :admin_settings

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :approved, :super_user

  validates_confirmation_of :password
  validates_format_of :email,
                      :with => /\A([^@\s]+)@zone3000\.net\Z/i,
                      :message => 'Only Zone3000 local email is acceptable'

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def manage_department(department_ids)
    if department_ids.is_a?(Fixnum)
      dep = [department_ids]
    else
      if department_ids.is_a?(Array)
        begin
          dep = department_ids.map(&:id)
        rescue
          dep = department_ids.map(&:to_i)
        end
      end
    end
    super_user? || (departments.map(&:id) & dep).any?
  end

  def name
    email
  end

end
