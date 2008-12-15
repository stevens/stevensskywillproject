require 'digest/sha2'
class Keeper < ActiveRecord::Base
  attr_protected :hashed_pwd, :enabled
  attr_accessor :password
  has_and_belongs_to_many :roles
  
  validates_presence_of :username
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_uniqueness_of :username, :case_sensitive => true
  validates_length_of :username, :within => 3..64
  validates_length_of :password, :within => 4..20, :if => :password_required?
  def before_save
    self.hashed_pwd = Keeper.encrypt(password) if !self.password.blank?
  end
  def password_required?
    self.hashed_pwd.blank? || !self.password.blank?
  end
  def self.encrypt(string)
    return Digest::SHA256.hexdigest(string)
  end
  def self.authenticate(username, password)
    find_by_username_and_hashed_pwd_and_enabled(username,Keeper.encrypt(password), true)
  end
  def has_role?(rolename)
    self.roles.find_by_name(rolename) ? true : false
  end
end
