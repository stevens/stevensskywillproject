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
	has_many :reviews, :order => "updated_at DESC"
  
  validates_as_attachment
	
	def errors_on_filename
		"文件名称有错误" if errors.invalid?('filename')
	end
	
	def errors_on_file_type
		"文件类型有错误" if errors.invalid?('content_type')
	end
	
	def errors_on_file_size
		"文件大小有错误" if errors.invalid?('size')
	end
	
	def is_cover?(photoable)
		id == photoable.cover_photo_id
	end
	
end
