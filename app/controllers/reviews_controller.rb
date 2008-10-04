class ReviewsController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	before_filter :load_reviewable_type, :only => [:index, :mine]
  
  # GET /reviews
  # GET /reviews.xml
  def index
		respond_to do |format|
      if @user && @user == @current_user
      	if @reviewable_type
      		format.html { redirect_to :action => 'mine', :reviewable_type => @reviewable_type.downcase }
      	else
      		format.html { redirect_to :action => 'mine' }
      	end
      else
		    load_reviews_set(@user) if !@parent_obj
		  	
		  	@show_todo = true if @parent_obj && @current_user
		  	
		  	info = "#{username_prefix(@user)}#{name_for(@reviewable_type)}#{REVIEW_CN} (#{@reviews_set_count})#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)

      	format.html # index.html.erb
      end
      format.xml  { render :xml => @reviews_set }
    end
  end 

  # GET /reviews/1
  # GET /reviews/1.xml
  def show

  end  
  
  # GET /reviews/new
  # GET /reviews/new.xml
  def new
		redirect_to @parent_obj if @parent_obj
  end

  # GET /reviews/1/edit
  def edit
  	load_review(@current_user)
		
		respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "input_form_for_review_#{@review.id}", 
													  :partial => "/reviews/review_input", 
												    :locals => {:reviewable => @review.reviewable,
												 						    :review => @review, 
												 						    :is_new => false, 
												 						    :review_error => false,  
												 						    :review_text => @review.review}
					page.show "input_form_for_review_#{@review.id}"
					page.hide "review_#{@review.id}_main"
					page.hide "review_#{@review.id}_todo"
				end				
			end
		end
  end
  
  # POST /reviews
  # POST /reviews.xml
  def create
    @review = @parent_obj.reviews.build(params[:review])
		@review.user_id = @current_user.id
		
		if @review.save
			after_create_ok
		else
			after_create_error
		end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    load_review(@current_user)

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
  	
  	if (@review.user == @current_user ) || (@review.reviewable.user == @current_user)
  		@review.destroy
  	end
		
		after_destroy_ok
  end
  
  def mine
    load_reviews_set(@current_user)
		
		@show_todo = true
		
  	info = "#{username_prefix(@current_user)}#{name_for(@reviewable_type)}#{REVIEW_CN} (#{@reviews_set_count})"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "reviews/index" }
      format.xml  { render :xml => @reviews_set }
    end
  end
  
	private
	
	def load_reviewable_type
		if @parent_type
			@reviewable_type = @parent_type
		elsif params[:reviewable_type]
			@reviewable_type = params[:reviewable_type].camelize
		end
	end
	
  def load_review(user = nil)
 		if user
 			@review = user.reviews.find(@self_id)
 		else
 			@review = Review.find(@self_id)
 		end
  end
  
  def load_reviews_set(user = nil)
 		@reviews_set = reviews_for(user, @reviewable_type, @parent_id)
  	@reviews_set_count = @reviews_set.size
  end
	
	def after_create_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
				redirect_to :action => 'index'
			end
			format.xml  { render :xml => @review, :status => :created, :location => @review }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_new_review", 
														:partial => "/layouts/notice", 
														:locals => {:notice => "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"}
					page.show "notice_for_new_review"
					page.replace_html "reviews_header", 
														:partial => "/layouts/index_header", 
							 							:locals => {:show_header_link => false, 
							 						 							:show_new_link => false, 
							 						 							:block_title => "#{name_for(@review.reviewable_type)}#{REVIEW_CN} (#{@review.reviewable.reviews.size})"}
					page.replace_html "reviews_detail", 
														:partial => "/layouts/items_list", 
							 							:locals => {:show_paginate => false,
													 						  :items_set => @review.reviewable.reviews, 
													 						  :limit => nil,
													 						  :itemable_sym => 'reviewable', 
													 						  :show_photo => true, 
													 						  :show_below_photo => false, 
													 						  :show_title => false, 
													 						  :show_photo_todo => false, 
													 						  :show_parent => false,
													 						  :show_todo => true, 
													 						  :delete_remote => true}
					page.replace_html "input_form_for_new_review",
														:partial => "/reviews/review_input",
													  :locals => {:reviewable => @review.reviewable,
													 						  :review => @review.reviewable.reviews.build, 
													 						  :is_new => true,  
													 						  :review_error => false, 
													 						  :review_text => ''}
					page.visual_effect :highlight, "review_#{@review.id}_main", :duration => 3								 						  
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end				
			end
		end
	end
	
	def after_create_error
		respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				render :action => "new"
			end
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_new_review", 
														:partial => "/layouts/notice", 
														:locals => {:notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"}
					page.show "notice_for_new_review"
					page.replace_html "input_form_for_new_review",
														:partial => "/reviews/review_input",
													  :locals => {:reviewable => @review.reviewable,
													 						  :review => @review.reviewable.reviews.build,
													 						  :is_new => true, 
													 						  :review_error => true,
													 						  :review_text => params[:review][:review]}
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end	
			end
		end
	end
	
	def after_update_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to @review
			end
			format.xml  { head :ok }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => "/layouts/notice", 
														:locals => {:notice => "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"}
					page.show "notice_for_review_#{@review.id}"
					page.hide "input_form_for_review_#{@review.id}"
					page.replace_html "review_#{@review.id}_main",
											 			:partial => "/reviews/review_main",
											 			:locals => {:item => @review}
					page.show "review_#{@review.id}_main"
					page.show "review_#{@review.id}_todo"
					page.visual_effect :highlight, "review_#{@review.id}_main", :duration => 3
					page.visual_effect :fade, "notice_for_review_#{@review.id}", :duration => 3
				end				
			end
		end
	end

	def after_update_error
		respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				render :action => "edit"
			end
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => "/layouts/notice", 
														:locals => {:notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"}
					page.show "notice_for_review_#{@review.id}"
					page.replace_html "input_form_for_review_#{@review.id}",
														:partial => "/reviews/review_input",
													  :locals => {:reviewable => @review.reviewable,
													 						  :review => @review,
													 						  :is_new => false, 
													 						  :review_error => true,
													 						  :review_text => params[:review][:review]}
				  page.visual_effect :fade, "notice_for_review_#{@review.id}", :duration => 3
				end	
			end
		end
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
    
    		if @parent_obj
    			load_reviews_set
    		else
    			load_reviews_set(@current_user)
    		end
    		
				current_page = params[:current_page].to_i if params[:current_page]
				page = page_for(current_page, @reviews_set_count)
				
				load_reviewable_type
				
				if @parent_obj
					redirect_to id_for(@parent_type).to_sym => @parent_id, :action => 'index', :page => page
				elsif @reviewable_type
					redirect_to :action => 'mine', :reviewable_type => @reviewable_type.downcase, :page => page
				else
					redirect_to :action => 'mine', :page => page
				end
			end
			format.xml  { head :ok }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_new_review", 
														:partial => "/layouts/notice", 
														:locals => {:notice => "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"}
					page.show "notice_for_new_review"
					page.replace_html "reviews_header", 
														:partial => "/layouts/index_header", 
							 							:locals => {:show_header_link => false, 
							 						 							:show_new_link => false, 
							 						 							:block_title => "#{name_for(@review.reviewable_type)}#{REVIEW_CN} (#{@review.reviewable.reviews.size})"}
					page.replace_html "reviews_detail", 
														:partial => "/layouts/items_list", 
							 							:locals => {:show_paginate => false,
													 						  :items_set => @review.reviewable.reviews, 
													 						  :limit => nil,
													 						  :itemable_sym => 'reviewable', 
													 						  :show_photo => true, 
													 						  :show_below_photo => false, 
													 						  :show_title => false, 
													 						  :show_photo_todo => false, 
													 						  :show_parent => false,
													 						  :show_todo => true, 
													 						  :delete_remote => true}
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end	
			end
		end
	end
	
end
