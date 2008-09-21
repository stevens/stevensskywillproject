class PhotosController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location, :only => [:index, :show, :mine]
  
  # GET /photos
  # GET /photos.xml
  def index	
  	if @parent_obj
  		load_photos_all			
  	end
  	
	 	info = "#{@parent_name}#{@self_name} (#{@photos_set_count}) > #{@parent_title}"
	 	
	 	photos_paginate
 		
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
	   	format.html # index.html.erb
      format.xml  { render :xml => @photos }
    end
  end 

  # GET /photos/1
  # GET /photos/1.xml
  def show
		load_photo
		
		if @parent_obj
			load_photos_all	
		end														
		
		if @photos_set_count == 1
			@photo_index = 1
		else
			get_prev_next
		end

		info = "#{@parent_name}#{@self_name} > #{@parent_title}"
		
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html do # show.html.erb
      	@photo_style = 'full'
      	@photo_file_url = photo_file_url(@photo, @parent_type, @photo_style)
      	@photo_url = @next_photo_url
      end
      format.xml  { render :xml => @photo }
      
      format.js do
      	@photo_style = 'detail'
      	@photo_file_url = photo_file_url(@photo, @parent_type, @photo_style)
      	@photo_url = @self_url	
				render :update do |page|
					page.replace_html "current_photo",
														:partial => "current_photo"
				end
			end
    end
  end  
  
  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = @current_user.photos.build
    
  	if @parent_obj
  		load_photos_all			
  	end
  	
    info = "新#{@parent_name}#{@self_name} > #{@parent_title}"
    
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
  	load_photo
    
  	if @parent_obj
  		load_photos_all			
  	end
    
  	@photo_style = 'list'
  	@photo_file_url = photo_file_url(@photo, @parent_type, @photo_style)
  	@photo_url = @self_url
   
 		info = "#{EDIT_CN}#{@parent_name}#{@self_name} > #{@parent_title}"
		
		set_page_title(info)
		set_block_title(info)
  end
  
  # POST /photos
  # POST /photos.xml
  def create
    @photo = @current_user.photos.build(params[:photo])
		@photo.photoable_type = @parent_type
		@photo.photoable_id = @parent_id
		
		if @parent_obj
  		load_photos_all			
  	end
		
		if !@photo.caption.blank? && @photo.caption.chars.length > TEXT_MAX_LENGTH_S
			@photo.errors_on_caption = "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_S}位"
			after_create_error
		else
		if @photos_set_count > 0
	      if @photo.save
					after_create_ok
	      else
					after_create_error
	      end
		else
      if @photo.save
      	# @parent_obj.cover_photo_id = @photo.id
				if @parent_obj.update_attribute('cover_photo_id', @photo.id)
					after_create_ok
				else
					@photo.destroy
					
					after_create_error
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
    load_photo

	  if @photo.update_attributes(params[:photo])
	    if params[:is_cover]
	    	# @parent_obj.cover_photo_id = @photo.id
				if @parent_obj.update_attribute('cover_photo_id', @photo.id)
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

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    load_photo
    
  	if @parent_obj
  		load_photos_all			
  	end
  	
    if @photo.is_cover?(@parent_obj)
    	if @photos_set_count == 1
    		cover_photo_id = nil
    	elsif @photos_set_count > 1
    		if @photo == @photos_set[0]
    			cover_photo_id = @photos_set[1].id
    		else
    			cover_photo_id = @photos_set[0].id
				end
    	end
    	if @parent_obj.update_attribute('cover_photo_id', cover_photo_id)
    		@photo.destroy
	   
				after_destroy_ok 
    	end
		else
	    @photo.destroy
	
			after_destroy_ok
    end
  end
  
	private
	
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
    @next_photo_url =	restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @next_photo.id}, nil)
    @prev_photo_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @prev_photo.id}, nil)
	end
	
  def load_photo
 		@photo = Photo.find(@self_id)
  	if @photo
  		@photo_alt = @photo.caption
  		@photo_user = @photo.user
  		@photo_user_title = @photo_user.login if @photo_user
  	end
  end
  
  def load_photos_all
 		@photos_set = photos_for(nil, @parent_type, @parent_id, 'created_at')
  	@photos_set_count = @photos_set.size
  end

  def photos_paginate
	 	@photos = @photos_set.paginate :page => params[:page], 
 															 		 :per_page => MATRIX_ITEMS_COUNT_PER_PAGE_M															 
  end
	
	def after_create_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
			format.html { redirect_to @selfs_url }
			format.xml  { render :xml => @photo, :status => :created, :location => @photo }
		end
	end
	
	def after_create_error
		respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		
			load_photos_all
			
			info = "新#{@parent_name}#{@self_name} > #{@parent_title}"
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
	end
	
	def after_update_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_to @self_url }
			format.xml  { head :ok }
		end
	end

	def after_update_error
		respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		
			load_photos_all
			
			info = "#{EDIT_CN}#{@parent_name}#{@self_name} > #{@parent_title}"
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
	end
	
	def after_destroy_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_to @selfs_url }
			format.xml  { head :ok }
		end
	end
	
end
