class PhotosController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location, :only => [:index, :show, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	before_filter :check_photoable_accessible
	before_filter :load_current_filter
	before_filter :load_photos_set, :except => [:new, :edit]
  
  # GET /photos
  # GET /photos.xml
  def index
  	info = "#{name_for(@parent_type)}#{ALBUM_CN} (#{@photos_set_count})#{itemname_suffix(@parent_obj)}"
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
	   	format.html # index.html.erb
      # format.xml  { render :xml => @photos_set }
      format.js do
      	render :update do |page|
      		if @current_filter
      			main_photo = @photos_set[0]
      		else
      			main_photo = cover_photo(@parent_obj)
      		end
					page.replace_html 'main_photo', 
														:partial => "/photos/photo_photo",
								 						:locals => { :photo => main_photo, 
																				 :show_cover => false, 
													 						   :focus_photo => nil, 
													 						   :photo_style => 'full', 
													 						   :show_photo_link => false, 
													 						   :photo_link_url => nil, 
													 						   :photo_link_remote => false,
													 						   :photo_filtered => false, 
													 						   :filter_type => 'photo_type' }
					page.replace_html 'photos_nav', 
														:partial => "/photos/photos_matrix",
													  :locals => { :show_paginate => false,
													 							 :photos_set => @photos_set,
													 							 :limit => nil, 
													 						   :show_photo => true, 
													 						   :focus_photo => nil, 
													 						   :photos_count_per_row => MATRIX_ITEMS_COUNT_PER_ROW_M, 
													 						   :photo_style => 'matrix', 
													 						   :photo_link_remote => true, 
													 						   :show_below_photo => false,
													 						   :show_cover => true, 
													 						   :show_photo_todo => false,
													 						   :photo_filtered => @current_filter ? true : false,
													 						   :filter_type => 'photo_type' }
					page.replace_html 'photos_filter_bar', 
														:partial => "/photos/photos_filter_bar", 
														:locals => { :photoable => @parent_obj, 
														 						 :current_filter => @current_filter, 
 														 						 :filter_type => 'photo_type' }
      	end
      end
    end
  end 

  # GET /photos/1
  # GET /photos/1.xml
  def show
		load_photo if @photoable_accessible

    respond_to do |format|
      format.html  do 
				if @photos_set_count == 1
					@photo_index = 1
					@photo_link_url = [@parent_obj, @photo]
				else
					get_prev_next
					@photo_link_url = [@parent_obj, @next_photo]
				end
				
				log_count(@photo)
		
		  	info = "#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)
				
      end # show.html.erb
      
      # format.xml  { render :xml => @photo }
      format.js do 
				render :update do |page|
					page.replace_html "main_photo", 
														:partial => "/photos/photo_photo",
								 						:locals => { :photo => @photo, 
																				 :show_cover => false, 
													 						   :focus_photo => nil, 
													 						   :photo_style => 'full', 
																				 :show_photo_link => false, 
													 						   :photo_link_url => nil, 
													 						   :photo_link_remote => false, 
													 						   :photo_filtered => false, 
													 						   :filter_type => 'photo_type' }
					page.replace_html "photos_nav", 
														:partial => "/photos/photos_matrix",
													  :locals => { :show_paginate => false,
														 						 :photos_set => @photos_set,
														 						 :limit => nil, 
														 						 :show_photo => true, 
														 						 :focus_photo => @photo, 
														 						 :photo_style => 'matrix', 
														 						 :photos_count_per_row => MATRIX_ITEMS_COUNT_PER_ROW_M,  
														 						 :photo_link_remote => true, 
														 						 :show_below_photo => false,
														 						 :show_cover => true, 
														 						 :show_photo_todo => false, 
														 						 :photo_filtered => @current_filter ? true : false,
														 						 :filter_type => 'photo_type' }
				end
      end
    end
  end  
  
  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = @parent_obj.photos.build if @parent_obj.user == @current_user
    @photo.photo_type = '99'
    
   	info = "新#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      # format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
  	load_photo(@current_user)
    
  	@photo_file_url = photo_file_url(@photo, @parent_type, 'list')
  	@photo_url = @self_url
   
   	info = "#{EDIT_CN}#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
		set_page_title(info)
		set_block_title(info)
  end
  
  # POST /photos
  # POST /photos.xml
  def create
    @photo = @parent_obj.photos.build(params[:photo])
    @photo.user_id = @current_user.id
    item_client_ip(@photo)
		
		if !@photo.caption.blank? && @photo.caption.chars.length > TEXT_MAX_LENGTH_S
			@photo.errors_on_caption = "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_S}位"
			after_create_error
		else
			ActiveRecord::Base.transaction do
	      if @photo.save
			    if params[:is_cover] || !@parent_obj.cover_photo_id
						if @parent_obj.update_attribute(:cover_photo_id, @photo.id)
							after_create_ok
						else
							@photo.destroy
							after_create_error
			      end
					else
						after_create_ok
					end
	      else
					after_create_error
	      end
			end
		end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    load_photo(@current_user)
    
		if !params[:photo][:caption].blank? && params[:photo][:caption].chars.length > TEXT_MAX_LENGTH_S
			@photo.errors_on_caption = "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_S}位"
			after_update_error
		else
			ActiveRecord::Base.transaction do
			  if @photo.update_attributes(params[:photo])
			    if params[:is_cover]
						if @parent_obj.update_attribute(:cover_photo_id, @photo.id)
							after_update_ok
						else
							after_update_error
			      end
					else
						after_update_ok
		   		end
			  else
					after_update_error
			  end
		  end
		end
  end
  
	def destroy
		load_photo(@current_user)
		
		if @photos_set_count == 1
			if item_published?(@parent_obj)
				@notice = "#{SORRY_CN}, 由于已发布的#{name_for(@parent_type)}至少需要有1#{unit_for('Photo')}#{PHOTO_CN}, 所以目前还不能#{DELETE_CN}这#{unit_for('Photo')}#{PHOTO_CN}!"
			else
				do_destroy = true
				change_cover = true
				new_cover_id = nil
				set_draft = true if @parent_obj.read_attribute('is_draft') == '0'
			end
		elsif @photos_set_count > 1
			do_destroy = true
			if @photo.is_cover?(@parent_obj)
				change_cover = true
				if @photo == @photos_set[0]
					new_cover_id = @photos_set[1].id
				else
					new_cover_id = @photos_set[0].id
				end
			end
		end
		
		if do_destroy
			ActiveRecord::Base.transaction do
				if @photo.destroy
					if change_cover
						if set_draft
							new_attrs = { :cover_photo_id => new_cover_id, :is_draft => '1' }
						else
							new_attrs = { :cover_photo_id => new_cover_id }
						end
						if @parent_obj.update_attributes(new_attrs)
							after_destroy_ok
						else
							after_destroy_error
						end
					else
						after_destroy_ok
					end
				else
					after_destroy_error
				end
			end
		else
			after_destroy_error
		end
  end
  
  def set_cover
  	load_photo(@current_user)
  	
  	if @parent_obj.update_attribute(:cover_photo_id, @photo.id)
			respond_to do |format|
	  		format.js do
	  			render :update do |page|
	  				flash[:notice] = "你已经将这#{unit_for('Photo')}#{PHOTO_CN}设置为#{name_for(@parent_type)}封面!"
	  				page.redirect_to [@parent_obj, @photo]
	  			end
				end
			end
		end
  end
  
	private
	
	def check_photoable_accessible
		if @parent_obj
			@photoable_accessible = photoable_accessible?(@parent_obj)
		end
	end
	
	def get_prev_next
    1.upto(@photos_set_count) do |i|
    	if @photos_set[i-1] == @photo
    		@photo_index = i
    		if i == 1
    			@next_photo = @photos_set[1]
    			@prev_photo = @photos_set[@photos_set_count-1]
    		elsif i == @photos_set_count
    			@next_photo = @photos_set[0]
    			@prev_photo = @photos_set[@photos_set_count-2]
    		else
    			@next_photo = @photos_set[i]
    			@prev_photo = @photos_set[i-2]
    		end
    		break
    	end
    end
	end
	
  def load_photo(user = nil)
 		if user
 			@photo = user.photos.find(@self_id)
 		else
 			@photo = Photo.find(@self_id)
 		end
  end
  
  def load_photos_set(user = nil)
  	if @photoable_accessible
  		@photo_type = params[:filter]
	 		@photos_set = photos_for(user, photo_conditions(@parent_type, @parent_id, @photo_type))
	  	@photos_set_count = @photos_set.size
  	end
  end
	
	def after_create_ok
		respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
				redirect_to :action => 'index'
			end
			# format.xml  { render :xml => @photo, :status => :created, :location => @photo }
		end
	end
	
	def after_create_error
		respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				load_photos_set
				
		   	info = "新#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			# format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		end
	end
	
	def after_update_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to [@parent_obj, @photo]
			end
			# format.xml  { head :ok }
		end
	end

	def after_update_error
		respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				load_photos_set
				
		   	info = "#{EDIT_CN}#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)
				
				render :action => "edit"
				clear_notice
			end
			# format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		end
		
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to :action => 'index'
			end
			# format.xml  { head :ok }
		end
	end
	
	def after_destroy_error
		respond_to do |format|
			format.html do
				if @notice
					flash[:notice] = @notice
				else
					flash[:notice] = "#{SORRY_CN}, #{DELETE_CN}#{PHOTO_CN}没有成功, 请重新#{DELETE_CN}!"
				end
				redirect_back_or_default('/')
			end
		end
	end
	
end
