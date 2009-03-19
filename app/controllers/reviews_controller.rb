class ReviewsController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
  
  #引用
  def quotation
  	load_review
  	
  	respond_to do |format|
  		format.js do
  			render :update do |page|
					page.redirect_to "#input_form_for_new_review"
					page.replace_html "input_form_for_new_review",
														:partial => 'reviews/review_input',
													  :locals => { :reviewable => @review.reviewable,
													 						   :review => @review.reviewable.reviews.build, 
													 						   :is_new => true,  
													 						   :review_error => false,  
													 						   :review_text => '', 
													 						   :quotation_submitter_id => @review.user_id, 
							 													 :quotation => @review.review,
							 													 :ref => params[:ref] }
				end
			end
		end
  end
  
  def index
		respond_to do |format|
			reviewable_type = params[:reviewable_type].camelize if !params[:reviewable_type].blank?
      if @user && @user == @current_user
      	format.html do
      		if params[:reviewable_type]
      			redirect_to url_for(:controller => 'reviews', :action => 'mine', :reviewable_type => params[:reviewable_type], :filter => params[:filter])
      		else
      			redirect_to url_for(:controller => 'reviews', :action => 'mine', :filter => params[:filter])
      		end
      	end
      else
      	if @user
					load_reviews_set(@user)
      		@show_filter_bar = true
      		info = "#{username_prefix(@user)}#{name_for(reviewable_type)}#{REVIEW_CN}"
	      elsif @parent_obj && @parent_obj.accessible?(@current_user)
	      	@reviewable = @parent_obj
	      	@reviews_set = @reviewable.reviews.find(:all)
	      	@reviews_set_count = @reviews_set.size
	      	info = "#{@parent_name}#{REVIEW_CN} (#{@reviews_set_count}) #{itemname_suffix(@parent_obj)}"
	      else
	      	@reviews_set = reviewable_type_reviews(reviewable_type)
	      	info = "#{name_for(reviewable_type)}#{REVIEW_CN}"
	      end
	         
				set_page_title(info)
				set_block_title(info)
	      format.html
			end
    end
  end 

  def show

  end  

  def new
		redirect_to item_link_url(@parent_obj) if @parent_obj
  end

  def edit
  	load_review(@current_user)
		
		respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "input_form_for_review_#{@review.id}", 
													  :partial => 'reviews/review_input', 
												    :locals => { :reviewable => @review.reviewable,
												 						     :review => @review, 
												 						     :is_new => false, 
												 						     :review_error => false,  
												 						     :review_text => @review.review,
												 						     :quotation_submitter_id => nil,
													 						   :quotation => nil,
													 						   :ref => params[:ref] }
					page.show "input_form_for_review_#{@review.id}"
					page.hide "review_#{@review.id}_main"
					page.hide "review_#{@review.id}_todo"
				end				
			end
		end
  end

  def create
    @review = @parent_obj.reviews.build(params[:review])
		@review.user_id = @current_user.id
		item_client_ip(@review)
		
		unless review_duplicate?(@review)
			if @review.save
				case params[:ref]
				when 'reviewable'
					@reviews_set = @parent_obj.reviews.find(:all, :limit => 20)
					limit = 20
				when 'reviewable_reviews_list'
					@reviews_set = @parent_obj.reviews.find(:all)
					@show_paginate = true
					limit = 50
				end
				@reviews_set_count = @reviews_set.size
				@insert_line = true if @reviews_set_count <= limit
                                expire_reviews_cache()
				after_create_ok
			else
				after_create_error
			end
		end
  end

  def update
    load_review(@current_user)

		if @review.update_attributes(params[:review])
			after_update_ok
                        expire_reviews_cache()
		else
			after_update_error
		end
  end

  def destroy
    load_review
  	
  	if item_manageable?(@review) || item_manageable?(@review.reviewable)
  		@reviewable = @review.reviewable
  		@review.destroy
			if params[:ref] == 'reviewable'
				@reviews_set = @reviewable.reviews.find(:all, :limit => 20)
				@reviews_set_count = @reviews_set.size
			end
		expire_reviews_cache()	 		
  		after_destroy_ok
  	end
  end
  
  def mine
  	reviewable_type = params[:reviewable_type].camelize if !params[:reviewable_type].blank?
		load_reviews_set(@current_user)
		@show_filter_bar = true
		info = "#{username_prefix(@current_user)}#{name_for(reviewable_type)}#{REVIEW_CN}"
		
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => 'reviews/index' }
    end
  end
  
	private
  def expire_reviews_cache()
    expire_fragment(%r{recipes/overview.part=overview_reviews.*})
  end	
  def load_review(user = nil)
 		if user
 			@review = user.reviews.find(@self_id)
 		else
 			@review = Review.find(@self_id)
 		end
  end
  
  def load_reviews_set(user = nil)
		@reviews_set = filtered_reviews_set(user, params[:reviewable_type], params[:filter])
		@reviews_set_count = @reviews_set.size
  end
	
	def after_create_ok
		respond_to do |format|
			format.js do
				render :update do |page|
					page.redirect_to "#reviewable_reviews_wrapper"
					page.replace_html "notice_for_new_review", 
														:partial => 'layouts/notice', 
														:locals => { :notice => "你已经发表了1#{@self_unit}#{name_for(@review.reviewable_type)}#{@self_name}!" }
					page.show "notice_for_new_review"
					if params[:ref] == 'reviewable_reviews_list'
						page.replace_html "reviewable_reviews_header", 
															:partial => 'reviews/reviewable_reviews_header', 
															:locals => { :reviewable => @parent_obj,
															 						 :reviews_set_count => @reviews_set_count }
					end
					if @insert_line
						page.insert_html :top, "reviewable_reviews_list_content", 
														 :partial => 'reviews/review_line', 
														 :locals => { :review => @review,
														 							:show_reviewer_photo => true, 
														 							:reviewer_photo_style => 'sign',
														 							:show_below_reviewer_photo => false,
														 							:show_review_title => false,
														 							:show_review_todo => true,
														 							:ref => params[:ref] }
					else
						page.replace_html "reviewable_reviews_list",
															:partial => 'reviews/reviewable_reviews_list', 
									 						:locals => { :reviews_set => @reviews_set,
															 						 :limit => nil, 
															 						 :show_paginate => @show_paginate,
															 						 :show_reviewer_photo => true, 
														 							 :reviewer_photo_style => 'sign',
														 							 :show_below_reviewer_photo => false,
														 							 :show_review_title => false,
														 							 :show_review_todo => true,
														 							 :ref => params[:ref] }
					end
					if params[:ref] == 'reviewable'
						case @review.reviewable_type
						when 'Recipe'
							page.replace "stats_entry_of_review",
													 :partial => 'layouts/stats_entry', 
										 			 :locals => { :stats_entry => [ 'review', @parent_obj.reviews.size, unit_for('Review'), REVIEW_CN ] }
						when 'Match'
							page.replace "stats_entry_of_match_#{@parent_id}_review_s",
													 :partial => 'layouts/stats_entry_s', 
													 :locals => { :stats_entry => [ [ 'review', @parent_type, @parent_id ], [ @parent_obj.reviews.size, unit_for('Review'), REVIEW_CN ] ] }
						end
					end
					page.replace_html "input_form_for_new_review",
														:partial => 'reviews/review_input',
													  :locals => { :reviewable => @parent_obj,
													 						   :review => @parent_obj.reviews.build, 
													 						   :is_new => true,  
													 						   :review_error => false, 
													 						   :review_text => '',
													 						   :quotation_submitter_id => nil,
													 						   :quotation => nil,
													 						   :ref => params[:ref] }
					page.visual_effect :highlight, "review_#{@review.id}_main", :duration => 3								 						  
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end				
			end
		end
	end
	
	def after_create_error
		respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "notice_for_new_review", 
														:partial => 'layouts/notice', 
														:locals => { :notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!" }
					page.show "notice_for_new_review"
					page.replace_html "input_form_for_new_review",
														:partial => 'reviews/review_input',
													  :locals => { :reviewable => @review.reviewable,
													 						   :review => @review.reviewable.reviews.build,
													 						   :is_new => true, 
													 						   :review_error => true,
													 						   :review_text => params[:review][:review], 
													 						   :quotation_submitter_id => params[:review][:quotation_submitter_id], 
						 														 :quotation => params[:review][:quotation],
						 														 :ref => params[:ref] }
				  page.visual_effect :fade, "notice_for_new_review", :duration => 3
				end	
			end
		end
	end
	
	def after_update_ok
		respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => 'layouts/notice', 
														:locals => { :notice => "你已经#{UPDATE_CN}了1#{@self_unit}#{name_for(@review.reviewable_type)}#{@self_name}!" }
					page.show "notice_for_review_#{@review.id}"
					page.hide "input_form_for_review_#{@review.id}"
					page.replace_html "review_#{@review.id}_main",
											 			:partial => 'reviews/review_main',
											 			:locals => { :review => @review }
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
			format.js do
				render :update do |page|
					page.replace_html "notice_for_review_#{@review.id}", 
														:partial => 'layouts/notice', 
														:locals => { :notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!" }
					page.show "notice_for_review_#{@review.id}"
					page.replace_html "input_form_for_review_#{@review.id}",
														:partial => 'reviews/review_input',
													  :locals => { :reviewable => @review.reviewable,
													 						   :review => @review,
													 						   :is_new => false, 
													 						   :review_error => true,
													 						   :review_text => params[:review][:review], 
													 						   :quotation_submitter_id => nil, 
													 						   :quotation => nil, 
													 						   :ref => params[:ref] }
				  page.visual_effect :fade, "notice_for_review_#{@review.id}", :duration => 3
				end	
			end
		end
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.html do
				flash[:notice] = "你已经#{DELETE_CN}了1#{@self_unit}#{name_for(type_for(@reviewable))}#{@self_name}!"
    
    		if @parent_obj
    			load_reviews_set
    		else
    			# @current_filter = params[:current_filter] if params[:current_filter]
    			load_reviews_set(@current_user)
    		end
    		
				current_page = params[:current_page].to_i if params[:current_page]
				page = page_for(current_page, @reviews_set_count)
				
				load_reviewable_type
				
				if @parent_obj
					redirect_to id_for(@parent_type).to_sym => @parent_id, :action => 'index', :page => page
				elsif @reviewable_type
					redirect_to :action => 'mine', :reviewable_type => @reviewable_type.downcase, :filter => params[:filter], :page => page
				else
					redirect_to :action => 'mine', :filter => params[:filter], :page => page
				end
			end
			format.js do
				render :update do |page|
					reviewable_type = type_for(@reviewable)
					@notice = "你已经#{DELETE_CN}了1#{@self_unit}#{name_for(reviewable_type)}#{@self_name}!"
					page.replace_html "flash_wrapper", 
														:partial => "/layouts/flash",
											 			:locals => { :notice => @notice }
					page.show "flash_wrapper"
					if params[:ref] == 'reviewable'
						page.replace_html "reviewable_reviews_list",
															:partial => 'reviews/reviewable_reviews_list', 
									 						:locals => { :reviews_set => @reviews_set,
															 						 :limit => nil, 
															 						 :show_paginate =>false,
															 						 :show_reviewer_photo => true, 
														 							 :reviewer_photo_style => 'sign',
														 							 :show_below_reviewer_photo => false,
														 							 :show_review_title => false,
														 							 :show_review_todo => true,
														 							 :ref => params[:ref] }
						case @review.reviewable_type
						when 'Recipe'
							page.replace "stats_entry_of_review",
													 :partial => 'layouts/stats_entry', 
										 			 :locals => { :stats_entry => [ 'review', @reviewable.reviews.size, unit_for('Review'), REVIEW_CN ] }
						when 'Match'
							page.replace "stats_entry_of_match_#{@reviewable.id}_review_s",
													 :partial => 'layouts/stats_entry_s', 
													 :locals => { :stats_entry => [ [ 'review', type_for(@reviewable), @reviewable.id ], [ @reviewable.reviews.size, unit_for('Review'), REVIEW_CN ] ] }
						end
					elsif params[:ref] == 'reviewable_reviews_list'
						flash[:notice] = @notice
						reviewable_id_sym = id_for(reviewable_type).to_sym
						page.redirect_to url_for(reviewable_id_sym => @reviewable.id, :controller => 'reviews', :action => 'index', :ref => params[:ref], :filter => params[:filter], :page => params[:page])
					elsif params[:ref] == 'user_reviews_list'
						flash[:notice] = @notice
						page.redirect_to url_for(:controller => 'reviews', :action => 'mine', :ref => params[:ref], :filter => params[:filter], :page => params[:page])
					end
				end	
			end
		end
	end
	
end
