require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :recipes, :order => "updated_at DESC"
  has_many :photos, :order => "created_at"
  has_many :reviews, :order => "updated_at DESC"
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email,
  													:message => "这一项是#{REQUIRED_CN}"
  validates_presence_of     :password,                   :if => :password_required?,
  													:message => "请输入#{PASSWORD_CN}"
  validates_presence_of     :password_confirmation,      :if => :password_required?,
  													:message => "请再次输入#{PASSWORD_CN}"
  validates_length_of       :login,    
  													:within => STRING_MIN_LENGTH_S..STRING_MAX_LENGTH_S,
  													:too_short => "字数太短，应为#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位",
  													:too_long => "字数太长，应为#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位"
  validates_length_of       :email,    
  													:within => STRING_MIN_LENGTH_M..STRING_MAX_LENGTH_L,
  													:too_short => "字数太短，应为#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位",
  													:too_long => "字数太长，应为#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位位"
	validates_length_of       :password, :password_confirmation,
														:within => STRING_MIN_LENGTH_M..STRING_MAX_LENGTH_M, 					 :if => :password_required?,
  													:too_short => "字数太短，应为#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应为#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_M}位"
	validates_format_of 			:email,
														:with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
														:message => "#{EMAIL_ADDRESS_CN}格式不正确"
  validates_format_of 			:password, 									 :if => :password_required?,
														:with => /^[A-Za-z0-9._%+-]+$/,
														:message => "#{PASSWORD_CN}只能包含英文字母（区分大小写）、数字（0-9）和半角符号（._%+-）"
  validates_confirmation_of :password,                   :if => :password_required?,
  													:message => "两次#{PASSWORD_CN}不匹配"
  validates_uniqueness_of   :login, :case_sensitive => false,
  													:message => "#{ACCOUNT_ID_CN}已经存在"
  validates_uniqueness_of   :email, :case_sensitive => false,
  													:message => "#{EMAIL_ADDRESS_CN}已经存在"												

  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
    # save
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
end
