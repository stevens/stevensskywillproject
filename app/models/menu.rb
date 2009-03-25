class Menu < ActiveRecord::Base
  include ApplicationHelper

	acts_as_taggable
	acts_as_rateable :average => true

  belongs_to :user

  has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id

	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :entries, :dependent => :destroy, :as => :entriable, :foreign_key => :entriable_id, :order => "created_at DESC"
  has_many :courses, :dependent => :destroy, :order => "course_type, created_at"

  validates_presence_of :title, :description, :from_type, :privacy,
                          :message => "这一项是#{REQUIRED_CN}"
  validates_presence_of :meal_duration,
                          :message => "请#{SELECT_CN}用餐时段"
	validates_presence_of :meal_kind,
                          :message => "请#{SELECT_CN}用餐性质"
  validates_presence_of :meal_system,
                          :message => "请#{SELECT_CN}用餐结构"
  validates_presence_of :place_area, 
                          :message => "请#{SELECT_CN}所在区域"
  validates_presence_of :place_subarea,
                          :message => "请#{SELECT_CN}所在子区域"
  validates_presence_of :place_type,
                          :message => "请#{SELECT_CN}用餐地点类型"
  validates_presence_of :from_where, :if => :from_where_required?,
                          :message => "请#{INPUT_CN}#{MENU_CN}的#{FROM_WHERE_CN}"
#  validates_inclusion_of :from_where, :if => :from_where_not_required?,
#														:in => %w( ),
#														:message => "请不要#{INPUT_CN}#{MENU_CN}的#{FROM_WHERE_CN}"
  validates_length_of :title,
                        :within => 2..STRING_MAX_LENGTH_M,
                        :too_short => "字数太短, 应该是2到#{STRING_MAX_LENGTH_M}位",
                        :too_long => "字数太长, 应该是2到#{STRING_MAX_LENGTH_M}位"
  validates_length_of :description,
                        :within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_L,
                        :too_short => "字数太短, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_L}位",
                        :too_long => "字数太长, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_L}位"
  validates_length_of :any_else,
                        :maximum => TEXT_MAX_LENGTH_L,
                        :too_long => "字数太长, 最多不应该超过#{TEXT_MAX_LENGTH_L}位"
#  validates_length_of :meal_time_notes, :place_notes, :person_notes, :bill_notes,
#                        :maximum => STRING_MAX_LENGTH_XL,
#                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_XL}位"
  validates_length_of :place_area_detail, :place_title,
                        :maximum => STRING_MAX_LENGTH_M,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_M}位"
  validates_length_of :from_where,
                        :maximum => STRING_MAX_LENGTH_L,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_L}位"
  validates_length_of :meal_date, :allow_nil => true, :allow_blank => true, 
                        :is => 10,
                        :message => "日期不存在或者日期格式不正确, 请按\"yyyy-mm-dd\"格式#{INPUT_CN}"
  validates_format_of :meal_date, :allow_nil => true, :allow_blank => true,
                        :with => /^(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29)$/,
                        :message => "日期不存在或者日期格式不正确, 请按\"yyyy-mm-dd\"格式#{INPUT_CN}"
  validates_numericality_of :number_of_persons, :only_integer => true, :allow_nil => true,
                              :greater_than => 0, :less_than => 1000,
                              :message => "请#{INPUT_CN}1个1-999的整数"
  validates_numericality_of :total_to_pay, :only_integer => true, :allow_nil => true,
                              :greater_than => 0, :less_than => 1000000,
                              :message => "请#{INPUT_CN}1个1-999999的整数"

  def publishable?
    (item_publishable?(self) && courses.size > 0) ? true : false
  end

  def accessible?(someuser = nil)
    item_accessible?(self, someuser)
  end

  protected

	def from_where_required?
		from_type != '1' && (from_where.nil? || from_where.blank?)
	end

#	def from_where_not_required?
#		from_type == '1' && !from_where.blank?
#	end
end
