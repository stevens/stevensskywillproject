class ReviewsController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
  
  # GET /reviews
  # GET /reviews.xml
  def index
    if params[:reviewable_type]
    	@reviewable_type = params[:reviewable_type].downcase
    	@parent_type = @reviewable_type
    	@reviews_html_id_prefix = @reviewable_type
    else
    	@reviews_html_id_prefix = 'all'
    end
    
    load_reviews_set(@user)
   	items_paginate(@reviews_set)
   	@reviews = @items
    
  	if @user
  		info = "#{@user_title}的#{name_for(@reviewable_type)}#{@self_name} (#{@reviews_set_count})"
  		@reviews_html_id_suffix = "user_#{@user_id}"
  	else
			info = "#{name_for(@reviewable_type)}#{@self_name} (#{@reviews_set_count})"
			@reviews_html_id_suffix = "all_users"
  	end
  	
  	@reviews_html_id = "#{@reviews_html_id_prefix}_reviews_of_#{@reviews_html_id_suffix}"
  	
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
      if @user && @user == @current_user
      	@show_todo = true
      	format.html { redirect_to :controller => 'mine', :action => 'reviews', :reviewable_type => @reviewable_type }
      else
      	format.html # index.html.erb
      end
      format.xml  { render :xml => @reviews }
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
											 :partial => "/reviews/input_review", 
										   :locals => {:reviewable => @review.reviewable,
										 						   :review => @review, 
										 						   :is_new => false, 
										 						   :review_error => false,  
										 						   :review_text => @review.review}
					page.visual_effect :slide_down, "input_form_for_review_#{@review.id}"
					page.hide "review_#{@review.id}"
					page.hide "review_#{@review.id}_todo"
				end				
			end
		end
  end
  
  # POST /reviews
  # POST /reviews.xml
  def create
    @reviewable = @parent_obj
    @review = @reviewable.reviews.build(params[:review])
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
    load_review(@current_user)
  	
  	@review.destroy
		
		after_destroy_ok
  end
  
  #用于取消Ajax模式的edit框
  def cancle_input
    respond_to do |format|
			format.js do
				render :update do |page|
					page.visual_effect :slide_up, "input_form_for_review_#{params[:review_id]}"
					page.show "review_#{params[:review_id]}"
					page.show "review_#{params[:review_id]}_todo"
				end				
			end
    end  
  end
  
	private
	
  def load_review(user)
 		@review = user.reviews.find(@self_id)
  end
  
  def load_reviews_set(user)
 		@reviews_set = reviews_for(user, @parent_type, @parent_id, nil, nil, 'created_at DESC')
  	@reviews_set_count = @reviews_set.size
  end
	
	def after_create_ok
		respond_to do |format|
			# flash[:notice] = "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"
			format.html { redirect_to @selfs_url }
			format.xml  { render :xml => @review, :status => :created, :location => @review }
			format.js do
				render :update do |page|
					page.replace_html "reviews_for_#{@review.reviewable_type.downcase}_#{@review.reviewable_id}",
														:partial => "/reviews/reviewable_reviews",
													 	:locals => {:reviewable => @review.reviewable}
					page.replace_html "notice_for_new_review", 
														:partial => "/layouts/notice", 
														:locals => {:nid => "new_review", 
																				:notice => "你已经成功#{ADD_CN}了1#{@self_unit}新#{@self_name}!"}
					page.show "notice_for_new_review"
					page.replace_html "input_form_for_new_review",
														:partial => "/reviews/input_review",
													  :locals => {:reviewable => @review.reviewable,
													 						  :review => @review.reviewable.reviews.build, 
													 						  :is_new => true,  
													 						  :review_error => false, 
													 						  :review_text => ''}
					page.visual_effect :highlight, "review_#{@review.id}", :duration => 3								 						  
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end				
			end
		end
	end
	
	def after_create_error
		respond_to do |format|
			# flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_new_review", 
														:partial => "/layouts/notice", 
														:locals => {:nid => "new_review", 
													 						  :notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"}
					page.show "notice_for_new_review"
					page.replace_html "input_form_for_new_review",
														:partial => "/reviews/input_review",
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
			# flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_to @self_url }
			format.xml  { head :ok }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => "/layouts/notice", 
														:locals => {:nid => "review_#{@review.id}", 
													 						  :notice => "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"}
					page.show "notice_for_review_#{@review.id}"
					page.visual_effect :blind_up, "input_form_for_review_#{@review.id}"
					page.replace "review_#{@review.id}",
											 :partial => "/reviews/review_body",
											 :locals => {:item => @review}
					page.show "review_#{@review.id}"
					page.show "review_#{@review.id}_todo"
					page.visual_effect :highlight, "review_#{@review.id}", :duration => 3
					page.visual_effect :fade, "notice_for_review_#{@review.id}", :duration => 3
				end				
			end
		end
	end

	def after_update_error
		respond_to do |format|
			# flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => "/layouts/notice", 
														:locals => {:nid => "review_#{@review.id}", 
													 						  :notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"}
					page.show "notice_for_review_#{@review.id}"
					page.replace_html "input_form_for_review_#{@review.id}",
														:partial => "/reviews/input_review",
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
			flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_back_or_default('/') }
			format.xml  { head :ok }
			format.js do
				render :update do |page|
					page.replace_html "reviews_for_#{@review.reviewable_type.downcase}_#{@review.reviewable_id}",
														:partial => "/reviews/reviewable_reviews",
													 	:locals => {:reviewable => @review.reviewable}
				end	
			end
		end
	end
	
end
