class Course < ActiveRecord::Base
  include ApplicationHelper

	acts_as_taggable

  belongs_to :user
  belongs_to :menu

  has_one :score, :dependent => :destroy, :as => :scoreable, :foreign_key => :scoreable_id
  
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"

  validates_presence_of :title, 
                          :message => "这一项是#{REQUIRED_CN}"
	validates_presence_of :course_type,
                          :message => "请#{SELECT_CN}菜品类型"
  validates_length_of :title,
                        :within => 2..STRING_MAX_LENGTH_M,
                        :too_short => "字数太短, 应该是2到#{STRING_MAX_LENGTH_M}位",
                        :too_long => "字数太长, 应该是2到#{STRING_MAX_LENGTH_M}位"
#  validates_length_of :description,
#                        :within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_S,
#                        :too_short => "字数太短, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位",
#                        :too_long => "字数太长, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位"
  validates_length_of :description,
                        :maximum => 500,
                        :too_long => "字数太长, 最多不应该超过500位"
  validates_length_of :common_title,
                        :maximum => STRING_MAX_LENGTH_M,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_M}位"
  validates_length_of :course_unit,
                        :maximum => 10,
                        :too_long => "字数太长, 最多不应该超过10位"
  validates_numericality_of :list_price, :only_integer => true, :allow_nil => true,
                              :greater_than => 0, :less_than => 100000,
                              :message => "请#{INPUT_CN}1个1-99999的整数"
end
