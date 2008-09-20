class Photo < ActiveRecord::Base
	include ApplicationHelper
	
	has_attachment :storage => :file_system,
								 :size => 1.byte..1.megabyte,
								 :resize_to => '640x640>',
								 :thumbnails => { :medium => '320x320>', :mcube => '96x96!',
								 									:small => '160x160>', :scube => '48x48!',
								 									:tiny => '80x80>', :tcube => '24x24!' },
							   :content_type => :image,
							 	 :processor => 'Rmagick'
	belongs_to :user
	belongs_to :photoable, :polymorphic => true
	# has_many :reviews, :order => "updated_at DESC"
  
  attr_accessor :errors_on_caption
  
  validates_as_attachment
	
	before_create :change_filename
	
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
	
	protected
	
	def change_filename
		filename = "1111"
	end
	
end
