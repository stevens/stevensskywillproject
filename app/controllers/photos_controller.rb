class PhotosController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location, :only => [:index, :show, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	before_filter :check_photoable_accessible
	before_filter :load_photos_set
  
  # GET /photos
  # GET /photos.xml
  def index
  	info = "#{name_for(@parent_type)}#{PHOTO_CN} (#{@photos_set_count})#{itemname_suffix(@parent_obj)}"
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
	   	format.html # index.html.erb
      format.xml  { render :xml => @photos_set }
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
      
      format.xml  { render :xml => @photo }
      format.js do 
				render :update do |page|
					page.replace_html "main_photo", 
														:partial => "/photos/photo_photo",
								 						:locals => { :photo => @photo, 
																				 :show_cover => false, 
													 						   :photo_style => 'full', 
													 						   :photo_link_url => nil, 
													 						   :photo_link_remote => true }
					page.replace_html "photos_nav", 
														:partial => "/photos/photos_matrix",
													  :locals => { :show_paginate => false,
														 						 :photos_set => @photos_set,
														 						 :limit => nil, 
														 						 :show_photo => true, 
														 						 :focus_photo => @photo, 
														 						 :photo_style => 'matrix', 
														 						 :photo_link_remote => true, 
														 						 :show_below_photo => false,
														 						 :show_cover => true, 
														 						 :show_photo_todo => false }
				end
      end
    end
  end  
  
  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = @parent_obj.photos.build if @parent_obj.user == @current_user
    
   	info = "新#{name_for(@parent_type)}#{PHOTO_CN}#{itemname_suffix(@parent_obj)}"
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
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
      	@parent_obj.cover_photo_id = @photo.id
      	@parent_obj.published_at = @parent_obj.get_published_at
				if model_for(@parent_type).update(@parent_id, {:cover_photo_id => @parent_obj.cover_photo_id, :published_at => @parent_obj.published_at})
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
    load_photo(@current_user)

	  if @photo.update_attributes(params[:photo])
	    if params[:is_cover]
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
    load_photo(@current_user)
  	
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
    	@parent_obj.cover_photo_id = cover_photo_id
    	@parent_obj.is_draft = @parent_obj.get_is_draft
    	@parent_obj.published_at = @parent_obj.get_published_at
			if model_for(@parent_type).update(@parent_id, {:cover_photo_id => @parent_obj.cover_photo_id, :is_draft => @parent_obj.is_draft, :published_at => @parent_obj.published_at })
    		@photo.destroy
	   
				after_destroy_ok 
    	end
		else
	    @photo.destroy
	
			after_destroy_ok
    end
  end
  
	private
	
	def check_photoable_accessible
		if @parent_obj
			case @parent_type
			when 'Recipe'
				@photoable_accessible = recipe_accessible?(@parent_obj)
			end
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
	 		@photos_set = photos_for(user, photo_conditions(@parent_type, @parent_id))
	  	@photos_set_count = @photos_set.size
  	end
  end
	
	def after_create_ok
		respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
				redirect_to :action => 'index'
			end
			format.xml  { render :xml => @photo, :status => :created, :location => @photo }
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
			format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		end
	end
	
	def after_update_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to [@parent_obj, @photo]
			end
			format.xml  { head :ok }
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
			format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
		end
		
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to :action => 'index'
			end
			format.xml  { head :ok }
		end
	end
	
end
