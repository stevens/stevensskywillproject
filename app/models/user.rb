require 'digest/sha1'
class User < ActiveRecord::Base
	include CodesHelper

  has_many :recipes, :order => "published_at DESC, created_at DESC"
  has_many :photos, :order => "created_at"
  has_many :reviews, :order => "created_at DESC"
  has_many :ratings, :order => "updated_at DESC"
  has_many :feedbacks, :order => "created_at DESC"
  has_many :favorites, :order => "created_at DESC"
  has_many :contacts, :order => "contact_type, accepted_at DESC, created_at DESC"
	has_many :friends,
					 :through => :contacts,
					 :source => :contactor,
					 :conditions => "contact_type = 1", 
					 :order => "accepted_at DESC, created_at DESC"
  has_many :stories, :order => "created_at DESC"
  has_many :matches, :order => "start_at DESC, end_at DESC"
  has_many :org_matches, 
  				 :class_name => "Match", 
  				 :dependent => :destroy, 
  				 :as => :organiger, 
  				 :foreign_key => :organiger_id, 
  				 :order => "start_at DESC, end_at DESC"
 	has_many :entries, :order => "created_at DESC"
 	has_many :votes, :order => "created_at DESC"
 	has_many :get_votes, #获得的投票
  				 :class_name => "Vote", 
  				 :dependent => :destroy, 
  				 :as => :voteable, 
  				 :foreign_key => :voteable_id, 
  				 :order => "created_at DESC"
 	has_many :winners, :dependent => :destroy, :as => :winnerable, :foreign_key => :winnerable_id
 	has_many :match_actors, :order => "created_at DESC"
  has_one :profile
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email,
  													:message => "这一项是#{REQUIRED_CN}"
  validates_presence_of     :password,                   :if => :password_required?,
  													:message => "请#{INPUT_CN}#{PASSWORD_CN}"
  validates_presence_of     :password_confirmation,      :if => :password_required?,
  													:message => "请再次#{INPUT_CN}#{PASSWORD_CN}"
  validates_length_of       :login,    
  													:within => 2..STRING_MAX_LENGTH_S,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位"
  validates_length_of       :email,    
  													:within => STRING_MIN_LENGTH_M..STRING_MAX_LENGTH_L,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位"
	validates_length_of       :password, :password_confirmation,
														:within => STRING_MIN_LENGTH_M..STRING_MAX_LENGTH_M, 					 :if => :password_required?,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_M}位"
	validates_format_of 			:email,
														:with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
														:message => "#{EMAIL_ADDRESS_CN}格式不正确"
  validates_format_of 			:password, 									 :if => :password_required?,
														:with => /^[A-Za-z0-9._%+-]+$/,
														:message => "#{PASSWORD_CN}只能包含英文字母(区分大小写), 数字(0-9)和半角符号(._%+-)"
  validates_confirmation_of :password,                   :if => :password_required?,
  													:message => "两次#{INPUT_CN}的#{PASSWORD_CN}不匹配"
  # validates_uniqueness_of   :login, :case_sensitive => false,
  # 													:message => "#{NICKNAME_CN}已经存在"
  validates_uniqueness_of   :email, :case_sensitive => false,
  													:message => "#{EMAIL_ADDRESS_CN}已经存在"	
	validates_exclusion_of 		:login, 										 :if => :login_required?, 
	 													:in => %w( admin admins administrator administrators superuser superusers sys system systems beecook beecooks fengchu fengchus 蜂厨), 
	 													:message => "这个#{NICKNAME_CN}不可用"	
	# admin admins administrator administrators superuser superusers sys system systems beecook beecooks skywill yogaskywill haakaa cookcat cookcats cookie cookies sunjin sunjins sunjinn sunjinns fengchu fengchus nickchow zhouying yingzhou 蜂厨 疯厨 周颖
	
  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  # Activates the user in the database.
  def activate
    @activated = true
    # self.activated_at = Time.now.utc #此行变更为下一行
    self.activated_at = Time.now
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
  # def self.authenticate(login, password)
  #   u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
  #   u && u.authenticated?(password) ? u : nil
  # end  此代码段变更为下面的代码段
  
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
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

	def forgot_password
		@forgotten_password = true
		self.make_password_reset_code
	end

	def reset_password
		# First update the password_reset_code before setting the
		# reset_password flag to avoid duplicate email notifications.
		# update_attribute(:password_reset_code, nil) 此行变更为下一行
		self.password_reset_code = nil
		@reset_password = true
	end

	#used in user_observer
	def recently_forgot_password?
		@forgotten_password
	end

	def recently_reset_password?
		@reset_password
	end

	def self.find_for_forget(email)
		find :first, :conditions => ['email = ? AND activated_at IS NOT NULL', email]
	end
	
	#以下为新增方法，记录最近登录时间和累计登录次数
	def log_loggedin
		self.latest_loggedin_at = Time.now
		# User.increment_counter(:login_count, id)
		current_login_count = self.login_count ? self.login_count : 0
		self.login_count = current_login_count + 1
		save(false)
	end
	
	#判断用户是否为某个角色
	def is_role_of?(role_name)
		if roles
			role_code = codes_for(code_conditions('user_role', nil, nil, role_name), 1)[0].code
			roles.include?(role_code)
		else
			false
		end
	end

  protected
	
	# before filter 
	def encrypt_password
	  return if password.blank?
	  self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
	  self.crypted_password = encrypt(password)
	end
	  
	def password_required?
	  # crypted_password.blank? || !password.blank? 此行变更为下一行
	  crypted_password.blank? || !password.nil?
	end
	
	def login_required?
		!(recently_forgot_password? || recently_reset_password?)
	end
	
	def make_activation_code
	  self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
	end
  
  def make_password_reset_code
		self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
end
