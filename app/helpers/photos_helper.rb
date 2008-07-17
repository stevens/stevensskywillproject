module PhotosHelper

	def photo_size(photo_style)
		case photo_style
		when 'full'
			''
		when 'list'
			'small'
		when 'detail'
			'medium'
		when 'navigation'
			'scube'
		when 'thumbnail'
			'mcube'
		when 'sign_list'
			'scube'
		when 'sign_detail'
			'tiny'
		end
	end
	
	def default_photo_file_url(photoable_type, photo_style)
		if photo_style == 'full'
			"\default\/#{photoable_type}/\default_#{photoable_type}.png"
		else
			"\default\/#{photoable_type}/\default_#{photoable_type}_#{photo_size(photo_style)}.png"
		end
	end
	
	def photo_file_url(photo, photoable_type, photo_style)
		if photo
  		photo.public_filename(photo_size(photo_style))
  	else
  		default_photo_file_url(photoable_type, photo_style)
  	end
	end
	
	def photo_alt(photo, no_photo_info)
		if photo
			photo.caption
		else
			no_photo_info
		end
	end
	
	def photos_for(photoable_type, photoable_id, user)
		if user
			user.photos.find(:all, 
											 :conditions => { :thumbnail => nil, :photo_type => photoable_type, :belong_to_id => photoable_id},
											 :order => "created_at")
		else
			Photo.find(:all, 
								 :conditions => { :thumbnail => nil, :photo_type => photoable_type, :belong_to_id => photoable_id},
								 :order => "created_at")
		end
	end
	
	def cover_photo(photoable)
		if id = photoable.cover_photo_id
			Photo.find(id)
		end
	end

end
