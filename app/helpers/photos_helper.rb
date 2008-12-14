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
		when 'mini'
			'tcube'
		end
	end
	
	def photos_rows_count(photos_count, photos_count_per_row = MATRIX_ITEMS_COUNT_PER_ROW_M)
		items_rows_count(photos_count, photos_count_per_row)
	end
	
	def default_photo_file_url(photoable_type, photo_style)
		url_common = "\default\/#{photoable_type.downcase}/\default_#{photoable_type.downcase}"

		case photoable_type
		when 'User'
			file_ext = 'gif'
		else
			file_ext = 'png'
		end
		
		if photo_style == 'full'
			"#{url_common}.#{file_ext}"
		else
			"#{url_common}_#{photo_size(photo_style)}.#{file_ext}"
		end
	end
	
	def photo_file_url(photo, photoable_type, photo_style)
		if photo
  		photo.public_filename(photo_size(photo_style))
  	else
  		default_photo_file_url(photoable_type, photo_style)
  	end
	end
	
	def photo_dimension(photo, thumbnail = nil)
		if thumbnail
			if thumbnail_photo = Photo.find(:first, :conditions => { :parent_id => photo.id, :thumbnail => thumbnail })
				[thumbnail_photo.width, thumbnail_photo.height]
			else
				[0, 0]
			end
		else
			[photo.width, photo.height]
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
	
	def filtered_photos(photoable, filter_type, filter)
		photoable.photos.find(:all, :conditions => { filter_type.to_sym => filter })
	end

	def photos_for(user = nil, photo_conditions = photo_conditions, limit = nil, order = 'created_at')
		if user
			user.photos.find(:all, :limit => limit, :order => order, 
											 :conditions => photo_conditions)
		else
			Photo.find(:all, :limit => limit, :order => order, 
								 :conditions => photo_conditions)
		end
	end
  
  def photo_conditions(photoable_type = nil, photoable_id = nil, photo_type = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["photos.filename IS NOT NULL", 
  								"photos.filename <> ''", 
  								"photos.parent_id IS NULL", 
  								"photos.thumbnail IS NULL"]
  	conditions << "photos.photoable_type = '#{photoable_type}'" if photoable_type
  	conditions << "photos.photoable_id = #{photoable_id}" if photoable_id
  	conditions << "photos.photo_type = #{photo_type}" if photo_type
		conditions << "photos.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "photos.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end

end
