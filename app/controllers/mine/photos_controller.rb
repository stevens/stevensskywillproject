class Mine::PhotosController < ApplicationController
	include ApplicationHelper
	
	before_filter :protect
  before_filter :load_user
  before_filter :load_belong_to
  
  # GET /photos
  # GET /photos.xml
  def index
		@photos = @belong_to_photos.paginate :page => params[:page], 
 																				 :per_page => PHOTOS_COUNT_PER_PAGE, 
 																				 :conditions => { 'thumbnail IS NULL', 'user_id == @user.id' },
 																				 :order => 'created_at'
		
		@photo_groups_count = groups_count(@photos, PHOTOS_COUNT_PER_LINE)
		
 		info = sysinfo('300006', '', {:type => @belong_to_type, :title => @belong_to_title}, '', {:type => PHOTO_CN, :count => @belong_to_photos_count})
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
    @photo = @user.photos.find(params[:id]) 
    @photo_submitter = @photo.user
    @photo_style = 'full'
    
    get_prev_next
    
 		info = sysinfo('300002', SEE_CN, {:type => @belong_to_type, :title => @belong_to_title}, '', {:type => PHOTO_CN})
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo }
      
      format.js do
      	@photo_style = 'detail'
      	
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
    @photo = @user.photos.build
    
 		info = sysinfo('300002', ADD_CN, {:type => @belong_to_type, :title => @belong_to_title}, NEW_CN, {:type => PHOTO_CN})
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = @user.photos.find(params[:id])
    @photo_submitter = @photo.user
    
    @photo_style = 'list'
    
  	info = sysinfo('300002', EDIT_CN, {:type => @belong_to_type, :title => @belong_to_title}, '', {:type => PHOTO_CN})
		set_page_title(info)
		set_block_title(info)
  end
  
  # POST /photos
  # POST /photos.xml
  def create
    @photo = @user.photos.build(params[:photo])
		@photo.photo_type = @photo_type
		@photo.belong_to_id = @belong_to.id
		
		if has_photos?(@photo_type, @belong_to, @user)
			respond_to do |format|
	      if @photo.save
					flash[:notice] = sysinfo('100001', ADD_CN, nil , NEW_CN, {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
					format.html { redirect_to(@belong_to_path) }
	        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
	      else
	        flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => PHOTO_CN})
	        format.html { render :action => "new" }
	        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
	        
 					info = sysinfo('300002', ADD_CN, {:type => @belong_to_type, :title => @belong_to_title}, NEW_CN, {:type => PHOTO_CN})
					set_page_title(info)
					set_block_title(info)
	      end
	    end
		else
			respond_to do |format|
	      if @photo.save
	      	@belong_to.cover_photo_id = @photo.id
					if @belong_to.save
						flash[:notice] = sysinfo('100001', ADD_CN, nil , NEW_CN, {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
						format.html { redirect_to(@belong_to_path) }
		        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
					else
						@photo.destroy
		        flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => PHOTO_CN})
		        format.html { render :action => "new" }
		        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }

 						info = sysinfo('300002', ADD_CN, {:type => @belong_to_type, :title => @belong_to_title}, NEW_CN, {:type => PHOTO_CN})
						set_page_title(info)
						set_block_title(info)
	      	end        
	      else
	        flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => PHOTO_CN})
	        format.html { render :action => "new" }
	        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }

 					info = sysinfo('300002', ADD_CN, {:type => @belong_to_type, :title => @belong_to_title}, NEW_CN, {:type => PHOTO_CN})
					set_page_title(info)
					set_block_title(info)
	      end
	    end
		end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = @user.photos.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
		    if params[:is_cover]
		    	@belong_to.cover_photo_id = @photo.id
					if @belong_to.save
						flash[:notice] = sysinfo('100001', UPDATE_CN, nil , '', {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
						format.html { redirect_to(@photo_path) }
		        format.xml  { head :ok }
					else
						flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => PHOTO_CN})
						format.html { render :action => "edit" }
						format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
						
						info = sysinfo('300002', EDIT_CN, {:type => @belong_to_type, :title => @belong_to_title}, '', {:type => PHOTO_CN})
						set_page_title(info)
						set_block_title(info)
		      end
				end
				flash[:notice] = sysinfo('100001', UPDATE_CN, nil , '', {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
        format.html { redirect_to(@photo_path) }
        format.xml  { head :ok }
      else
	      flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => PHOTO_CN})
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
        
  			info = sysinfo('300002', EDIT_CN, {:type => @belong_to_type, :title => @belong_to_title}, '', {:type => PHOTO_CN})
				set_page_title(info)
				set_block_title(info)
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = @user.photos.find(params[:id])
    if @photo.is_cover?(@belong_to)
    	if @belong_to_photos_count == 1
    		@belong_to.cover_photo_id = nil
    	elsif @belong_to_photos_count > 1
    		if @photo.id == @belong_to_photos[0].id
    			@belong_to.cover_photo_id = @belong_to_photos[1].id
    		else
    			@belong_to.cover_photo_id = @belong_to_photos[0].id
				end
    	end
    	if @belong_to.save
    		@photo.destroy
	   
				respond_to do |format|
					flash[:notice] = sysinfo('100001', DELETE_CN, nil , '', {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
	      	format.html { redirect_to(@belong_to_path) }
	      	format.xml  { head :ok } 
	      end
    	end
		else
	    @photo.destroy
	
	    respond_to do |format|
				flash[:notice] = sysinfo('100001', DELETE_CN, nil , '', {:type => PHOTO_CN, :count => 1, :unit => UNIT_2_CN})
	      format.html { redirect_to(@belong_to_path) }
	      format.xml  { head :ok }
	    end
    end
  end
  
	private
  
  def load_belong_to
  	if #{@url}.include?#{RECIPE_EN.pluralize}
  		@photo_type = RECIPE_EN
  		@belong_to_type = RECIPE_CN
  		@belong_to_unit = UNIT_1_CN
  		if params[:recipe_id] && params[:id]
  			@belong_to = @user.recipes.find(params[:recipe_id])
  			@photo = Photo.find(params[:id])
	  		@photos_path = mine_recipe_photos_path(@belong_to)
	  		@photo_path = mine_recipe_photo_path(@belong_to, @photo)
	  		@new_photo_path = new_mine_recipe_photo_path(@belong_to)
	  		@edit_photo_path = edit_mine_recipe_photo_path(@belong_to, @photo)
  		elsif params[:recipe_id]
	  		@belong_to = @user.recipes.find(params[:recipe_id])
	  		@photos_path = mine_recipe_photos_path(@belong_to)
	  		@new_photo_path = new_mine_recipe_photo_path(@belong_to)
  		elsif params[:id]
  			@photo = Photo.find(params[:id])
  			@belong_to = @user.recipes.find(@photo.belong_to_id)
	  		@photos_path = mine_recipe_photos_path(@belong_to)
	  		@photo_path = mine_recipe_photo_path(@belong_to, @photo)
	  		@new_photo_path = new_mine_recipe_photo_path(@belong_to)
	  		@edit_photo_path = edit_mine_recipe_photo_path(@belong_to, @photo)
  		end
  		@belong_to_path = mine_recipe_path(@belong_to)
  	end
		@belong_to_title = @belong_to.title
		@belong_to_photos = photos_all(@photo_type, @belong_to, @user)
		@belong_to_photos_count = @belong_to_photos.size
  end
	
	def get_prev_next
    1.upto(@belong_to_photos_count) do |i|
    	if @belong_to_photos[i-1].id == @photo.id
    		@photo_index = i
    		if i == 1
    			@next_photo = @belong_to_photos[1]
    			@prev_photo = @belong_to_photos[@belong_to_photos_count-1]
    		elsif i == @belong_to_photos_count
    			@next_photo = @belong_to_photos[0]
    			@prev_photo = @belong_to_photos[@belong_to_photos_count-2]
    		else
    			@next_photo = @belong_to_photos[i]
    			@prev_photo = @belong_to_photos[i-2]
    		end
    	end
    end
	end
	
end
