class ReviewsController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
  
  # GET /reviews
  # GET /reviews.xml
  def index
  	
  	if @parent_obj
  		load_reviews_all			
  	end
  	
	 	info = "#{@parent_name}\"#{@parent_title}\"的#{@self_name}(#{@reviews_set_count})"
	 	
	 	reviews_paginate
 		
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
	   	format.html # index.html.erb
      format.xml  { render :xml => @reviews }
    end
  end 

  # GET /reviews/1
  # GET /reviews/1.xml
  def show
		load_review
		
		if @parent_obj
			load_reviews_all	
		end										
		
		info = "#{@parent_name}\"#{@parent_title}\"的#{@self_name}: #{@review_title}"
		
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @review }
    end
  end  
  
  # GET /reviews/new
  # GET /reviews/new.xml
  def new
    @review = @current_user.reviews.build
    
  	if @parent_obj
  		load_reviews_all			
  	end
  	
    info = "#{ADD_CN}#{@parent_name}\"#{@parent_title}\"的新#{@self_name}"
    
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @review }
    end
  end

  # GET /reviews/1/edit
  def edit
  	load_review
    
  	if @parent_obj
  		load_reviews_all			
  	end
   
 		info = "#{EDIT_CN}#{@parent_name}\"#{@parent_title}\"的#{@self_name}: #{@review_title}"
		
		set_page_title(info)
		set_block_title(info)
  end
  
  # POST /reviews
  # POST /reviews.xml
  def create
    @review = @current_user.reviews.build(params[:review])
		@review.reviewable_type = @parent_type
		@review.reviewable_id = @parent_id
		
		if @review.save
			after_create_ok
		else
			after_create_error
		end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    load_review

		if @review.update_attributes(params[:review])
			after_update_ok
		else
			after_update_error
		end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.xml
  def destroy
    load_review
  	
  	@review.destroy
		
		after_destroy_ok
  end
  
  def load_latest_reviews
  	@reviews_set = Review.find(:all, :order => 'created_at DESC', :limit => ITEMS_COUNT_PER_PAGE,
  														 :conditions => [ "title IS NOT NULL AND
  														 									title <> '' AND
  														 									review IS NOT NULL AND
  														 									review <> '' AND 
  														 									reviewable_type = 'recipe' AND
  														 									created_at >= ?", Time.today - 7.days ] )
  	@reviews_set_count = @reviews_set.size
  end
  
	private
	
  def load_review
 		@review = Review.find(@self_id)
  	if @review
  		@review_title = @review.title
  		@review_user = @review.user
  		@review_user_title = @review_user.login if @review_user
  	end
  end
  
  def load_reviews_all
 		@reviews_set = reviews_for(nil, @parent_type, @parent_id, 'created_at DESC')
  	@reviews_set_count = @reviews_set.size
  end

  def reviews_paginate
	 	@reviews = @reviews_set.paginate :page => params[:page], 
 																 		 :per_page => LIST_ITEMS_COUNT_PER_PAGE_S														 
  end
	
	def after_create_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
			format.html { redirect_to @selfs_url }
			format.xml  { render :xml => @review, :status => :created, :location => @review }
		end
	end
	
	def after_create_error
		respond_to do |format|
			flash[:notice] = "你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
		
			load_reviews_all
			
			info = "#{ADD_CN}#{@parent_name}\"#{@parent_title}\"的新#{@self_name}"
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
			flash[:notice] = "你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
		
			load_reviews_all
			
			info = "#{EDIT_CN}#{@parent_name}\"#{@parent_title}\"的#{@self_name}: #{@review_title}"
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
