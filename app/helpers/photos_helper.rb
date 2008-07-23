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
		when 'matrix'
			'mcube'
		when 'list'
			'small'
		when 'portrait'
			'small'
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
	
	def photos_for(user, photoable_type, photoable_id, order)
		if user
			if photoable_type && photoable_id
				user.photos.find(:all, :order => order, 
												 :conditions => ["photo_type = ? AND 
																			 	 belong_to_id = ?", 
																			 	 photoable_type, 
																			 	 photoable_id])
			else
				user.photos.find(:all, :order => order)
			end
		else
			if photoable_type && photoable_id
				Photo.find(:all, :order => order, 
									 :conditions => ["photo_type = ? AND 
																	 belong_to_id = ?", 
																	 photoable_type, 
																	 photoable_id])
			else
				Photo.find(:all, :order => order)
			end
		end
	end
	
	def cover_photo(photoable)
		if id = photoable.cover_photo_id
			Photo.find(id)
		end
	end

end
