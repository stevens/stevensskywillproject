# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_beecook_session',
    :secret      => '5b33a2f59b95e9d035acae7deb142cb3708f77c37ab54170f015f22d9a111f86bdad30e06b72089916c60a2546932474a073f5f98f67cc2f49a312da86833db9'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :homepage_observer, :contact_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Include your application configuration below
	
	# SITE constants
	STUDIO_NAME_EN = 'Cookies-Online'
	STUDIO_NAME_CN = '取奇傲蓝'
	SITE_NAME_EN = 'BeeCook'
	SITE_NAME_CN = '蜂厨'
	SLOGAN_CN = "美食大革命, 我厨我蜂狂!"
	SITE_DOMAIN_EN = 'www.beecook.com'
	SITE_DOMAIN_CN = 'www.蜂厨.com'
	SITE_EMAIL = 'beecook2007@gmail.com' #TBD
	YEAR_BEGIN = '2008'
	YEAR_NOW = '2008'
	
	# WHO constants
	I_CN = '我'
	MY_EN = 'my'
	MY_CN = '我的'
	
	WE_CN = '我们'
	OUR_CN = '我们的'
	
	YOU_CN = '你'
	YOUR_CN = '你的'
	
	YOUS_CN = '你们'
	YOUSR_CN = '你们的'
	
	HE_CN = '他'
	HIS_CN = '他的'
	
	THEY_HE_CN = '他们'
	THEIR_HE_CN = '他们的'
	
	SHE_CN = '她'
	HER_CN = '她的'
	
	THEY_SHE_CN = '她们'
	THEIR_SHE_CN = '她们的'
	
	IT_CN = '它'
	ITS_CN = '它的'
	
	THEY_IT_CN = '它们'
	THEIR_IT_CN = '它们的'
	
	# NUMBER constants
	N0_CN = '零'
	N1_CN = '一'
	N2_CN = '二'
	N3_CN = '三'
	N4_CN = '四'
	N5_CN = '五'
	N6_CN = '六'
	N7_CN = '七'
	N8_CN = '八'
	N9_CN = '九'
	N10_CN = '十'
	NH_CN = '百'
	NK_CN = '千'
	N10K_CN = '万'
	NHK_CN = '十万'
	NKK_CN = '百万'
	N10KK_CN = '千万'
	NHKK_CN = '亿'
	NKKK_CN = '十亿'
	
	# SYMBOL constants
	EXCLAMATION_MARK = '!'
	QUESTION_MARK = '?'
	FULL_STOP = '.'
	COMMA = ','
	COLON = ':'
	SEMICOLON = ';'
	SINGLE_QUOTATION_MARK_LEFT = '''
	SINGLE_QUOTATION_MARK_RIGHT = '''
	DOUBLE_QUOTATION_MARK_LEFT = '"'
	DOUBLE_QUOTATION_MARK_RIGHT = '"'
	BRACES_LEFT = '{'
	BRACES_RIGHT = '}'
	BRACKETS_LEFT = '['
	BRACKETS_RIGHT = ']'
	PARENTHESES_LEFT = '('
	PARENTHESES_RIGHT = ')' 
	
	# TIME constants
	HOUR_CN = '小时'
	MINUTE_CN = '分'
	SECOND_CN = '秒'
	
	# DO constants
	CREATE_CN = '创建'
	ADD_CN = '添加'
	EDIT_CN = '编辑'
	DELETE_CN = '删除'
	SEE_CN = '查看'
	SEESEE_CN = '看看'
	BROWSE_CN = '浏览'
	SEARCH_CN = '搜索'
	FIND_CN = '查找'
	FILTER_CN = '过滤'
	ASCEND_CN = '升序排列'
	DESCEND_CN = '降序排列'
	UPDATE_CN = '更新'
	SAVE_CN = '保存'
	SAVE_AS_CN = '另存为'
	SAVE_CHANGES_CN = '保存更新'
	SELECT_CN = '选择'
	INPUT_CN = '输入'
	OUTPUT_CN = '输出'
	IMPORT_CN = '导入'
	EXPORT_CN = '导出'
	DISPLAY_CN = '显示'
	PRINT_CN = '打印'
	OK_CN = '确定'
	CANCLE_CN = '取消'
	CHANGE_CN = '更改'
	GO_CN = '前往'
	INTO_CN = '进入'
	BACK_CN = '返回'
	LOGIN_CN = '登录'
	LOGOUT_CN = '退出'
	SIGN_UP_CN = '注册'
	SIGN_OFF_CN = '注销'
	BECOME_CN = '作为'
	RESET_CN = '重设'
	UPLOAD_CN = '上传'
	DOWNLOAD_CN = '下载'
	
	# KEY constants
	NAME_CN = '名字'
	TITLE_CN = '名称'
	TYPE_CN = '类型'
	CATEGORY_CN = '类别'
	SUBJECT_CN = '标题'
	CONTENT_CN = '内容'
	FROM_WHERE_CN = '来源'

	REVIEW_EN = 'review'
	REVIEW_CN = '评论'
	RESPOND_CN = '回应'
	RATE_CN = '评分'
	RANKING_CN = '榜单'
	TAG_CN = '标签'
	FAVORITE_CN = '收尝'

	RECIPE_EN = 'recipe'
	RECIPE_CN = '食谱'
	MENU_CN = '食单'
	KITCHEN_CN = '厨房'
	PREP_TIME_CN = '准备时间'
	COOK_TIME_CN = '制作时间'
	DIFFICULTY_CN = '难度'
	COST_CN = '成本'
	YIELD_CN = '出品量'
	DESCRIPTION_CN	= '描述'
	INGREDIENT_CN= '用料'
	DIRECTION_CN = '做法'
	TIP_CN = '小贴士'
	PRIVATE_HOME_CN = '私房'
	
	FILE_CN = '文件'	
	URL_CN = 'URL地址'
	VIDEO_CN = '视频'
	VIDEO_URL_CN = '视频地址'

	PHOTO_EN = 'photo'
	PHOTO_CN = '图片'	
	ALBUM_CN = '图册'
	CAPTION_CN = '标注'
	COVER_CN = '封面'
	
	USER_CN = '用户'
	PORTRAIT_CN = '头像'
	ACCOUNT_CN = '帐户'
	ACCOUNT_ID_CN = '帐户ID'
	PASSWORD_CN = '密码'
	EMAIL_CN = '邮件'
	EMAIL_ADDRESS_CN = 'Email'
	NICKNAME_CN = '昵称'
	GROUP_CN = '队伍'
	FRIEND_CN = '伙伴'
	INTERESTED_CN = '感兴趣的'
	PEOPLE_CN = '蜂友'
	PROFILE_CN = '档案'
	MAILBOX_CN = '信箱'
	SETTING_CN = '设置'
	PRIVACY_CN = '隐私'
	BRAIN_CN = '智囊'
	MAIN_PAGE_CN = '蜂窝'
	
	MATCH_CN = '比赛'
	ENTRY_CN = '参赛作品'
	PLAYER_CN = '选手'
	VOTE_CN = '投票'
	VOTER_CN = '投票者'
	AWARD_CN = '奖项'
	WINNING_CN = '获奖作品'
	WINNER_CN = '获奖者'
	
	ABOUT_CN = '关于'
	CONTACT_US_CN = '联系我们'
	PRIVACY_POLICY_CN = '隐私政策'
	TERMS_OF_SERVICE_CN = '服务条款'
	HELP_CN = '用户指南'
	FEEDBACK_CN = '反馈'
	
	#DISPLAY constants
	TITLE_LINKER = '>'
	
	HOME_CN = '首页'
	FIRST_PAGE_CN = '头页'
	LAST_PAGE_CN = '尾页'
	PREV_PAGE_CN = '上页'
	NEXT_PAGE_CN = '下页'
	PREV_ONE_CN = '上一'
	NEXT_ONE_CN = '下一'
	
	ALL_CN = '所有'
	MORE_CN = '更多'
	
	HELLO_CN = '你好'
	THANK_CN = '感谢'
	SORRY_CN = '对不起'
	
	INFO_CN = '信息'
	ERROR_CN = '错误'
	NEW_CN = '新'
	HAS_NO_CN = '还没有'
	REDO_CN = '重新'
	COME_FROM_CN = '来自'
	
	REQUIRED_CN = '必填项'
	OPTIONAL_CN = '选填项'
	
	#OBJECT constants
	CODE_USER_CN = '0'
	CODE_RECIPE_CN = '1'
	CODE_PHOTO_CN = '2'
	CODE_REVIEW_CN = '3'
	CODE_FAVORITE_CN = '4'

	UNIT_USER_CN = '位'
	UNIT_RECIPE_CN = '个'
	UNIT_PHOTO_CN = '张'
	UNIT_REVIEW_CN = '条'
	UNIT_FAVORITE_CN = '个'
	UNIT_MATCH_CN = '个'
	UNIT_ENTRY_CN = '项'
	UNIT_VOTE_CN = '票'
	UNIT_RATE_CN = '次'
	UNIT_AWARD_CN = '个'
	UNIT_MENU_CN = '份'
	
	#SIZE constants
	LIST_ITEMS_COUNT_PER_PAGE_S = 20
	LIST_ITEMS_COUNT_PER_PAGE_M = 50
	LIST_ITEMS_COUNT_PER_PAGE_L = 100
	
	MATRIX_ITEMS_COUNT_PER_PAGE_S = 12
	MATRIX_ITEMS_COUNT_PER_PAGE_M = 24
	MATRIX_ITEMS_COUNT_PER_PAGE_L = 48
	
	MATRIX_ITEMS_COUNT_PER_ROW_S = 4
	MATRIX_ITEMS_COUNT_PER_ROW_M = 6
	MATRIX_ITEMS_COUNT_PER_ROW_L = 8
	
	STRING_MIN_LENGTH_S = 3
	STRING_MIN_LENGTH_M = 6
	STRING_MIN_LENGTH_L = 9
	
	STRING_MAX_LENGTH_S = 30
	STRING_MAX_LENGTH_M = 60
	STRING_MAX_LENGTH_L = 90
	STRING_MAX_LENGTH_XL = 200
	
	TEXT_MIN_LENGTH_S = 5
	TEXT_MIN_LENGTH_M = 10
	TEXT_MIN_LENGTH_L = 20
	
	TEXT_MAX_LENGTH_S = 1000
	TEXT_MAX_LENGTH_M = 2000
	TEXT_MAX_LENGTH_L = 5000
	TEXT_MAX_LENGTH_XL = 10000
	
	TEXT_SUMMARY_LENGTH_S = 100
	TEXT_SUMMARY_LENGTH_M = 200
	TEXT_SUMMARY_LENGTH_L = 400
	
	HTML_TEXT_FIELD_SIZE_S = 30
	HTML_TEXT_FIELD_SIZE_M = 60
	HTML_TEXT_FIELD_SIZE_L = 90
	
	HTML_TEXT_AREA_ROWS_SIZE_S = 5 
	HTML_TEXT_AREA_ROWS_SIZE_M = 10
	HTML_TEXT_AREA_ROWS_SIZE_L = 15
	HTML_TEXT_AREA_ROWS_SIZE_XL = 20

	HTML_TEXT_ARER_COLUMNS_SIZE_S = 30
	HTML_TEXT_ARER_COLUMNS_SIZE_M = 60
	HTML_TEXT_ARER_COLUMNS_SIZE_L = 90
	
	MIN_HILIGHTED_ITEM_RATING = 7
	MAX_HILIGHTED_ITEM_RATING = 10
	MIN_RATINGS_COUNT = 5

	TAGS_COUNT_PER_PAGE = 300
	TAG_COUNT_AT_LEAST = 3
	TAG_COUNT_AT_MOST = nil
	TAGS_COUNT_LIMIT = 100
	
end
	
	# ActionMailer::Base.delivery_method = :smtp
	# ActionMailer::Base.smtp_settings = { }
	
	require 'will_paginate'
  # require 'action_mailer/ar_mailer' #后台管理用
	
	TagList.delimiter = " "
	Tag.destroy_unused = true
	
	CalendarDateSelect.format = :iso_date