class Photo < ActiveRecord::Base
	include ApplicationHelper
	
	has_attachment :storage => :file_system,
								 :content_type => :image,
								 :size => 1.byte..640.kilobytes,
								 :resize_to => '640x640>',
								 :thumbnails => { :lcube => '192x192!', 
								 									:medium => '320x320>', :mcube => '96x96!',
								 									:small => '160x160>', :scube => '48x48!',
								 									:tiny => '80x80>', :tcube => '24x24!' },
							 	 :processor => 'Rmagick'
	belongs_to :user
	belongs_to :photoable, :polymorphic => true
	# has_many :reviews, :order => "updated_at DESC"
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
  
  attr_accessor :errors_on_caption
  
  validates_as_attachment
	
	def errors_on_file
		if errors.invalid?('filename')
			"#{FILE_CN}名称有#{ERROR_CN}"
		elsif errors.invalid?('content_type')
			"#{FILE_CN}类型有#{ERROR_CN}"
		elsif errors.invalid?('size')
			"#{FILE_CN}大小有#{ERROR_CN}"
		end
	end
	
	def is_cover?(photoable)
		id == photoable.cover_photo_id
	end
	
	def is_focus?(focus_photo)
		(focus_photo && focus_photo == self) ? true : false
	end
	
end
