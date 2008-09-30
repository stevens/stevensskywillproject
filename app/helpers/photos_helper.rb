module PhotosHelper

	def photo_size(photo_style)
		case photo_style
		when 'full'
			''
		when 'detail'
			'medium'
		when 'navigation'
			'scube'		
		when 'matrix'
			'mcube'
		when 'list'
			'tiny'
		when 'portrait'
			'small'
		when 'sign'
			'scube'
		end
	end
	
	def photos_rows_count(photos_count, photos_count_per_row = MATRIX_ITEMS_COUNT_PER_ROW_M)
		items_rows_count(photos_count, photos_count_per_row)
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
	
	def cover_photo(photoable)
		if id = photoable.cover_photo_id
			Photo.find(id)
		else
			nil
		end
	end
	
	def user_portrait(user)
		user.photos.find(:first, 
										 :conditions => ["photoable_type = 'User' AND 
																		  photoable_id = ?", 
																		  user.id])
	end

	def photos_for(user, photoable_type, photoable_id, created_at_from = nil, created_at_to = nil, order = 'created_at')
		if user
			if photoable_type || photoable_id || created_at_from || created_at_to
				user.photos.find(:all, :order => order, 
												 :conditions => [photos_conditions(photoable_type, photoable_id, created_at_from, created_at_to)])
			else
				user.photos.find(:all, :order => order)
			end			
		else
			Photo.find(:all, :order => order, 
								 :conditions => [photos_conditions(photoable_type, photoable_id, created_at_from, created_at_to)])
		end
	end
  
  def photos_conditions(photoable_type, photoable_id, created_at_from = nil, created_at_to = nil)
  	conditions = []
  	conditions << "photoable_type = '#{photoable_type}'" if photoable_type
  	conditions << "photoable_id = #{photoable_id}" if photoable_id
		conditions << "photos.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "photos.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end

end
