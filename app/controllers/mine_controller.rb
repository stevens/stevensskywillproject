class MineController < ApplicationController
	
	before_filter :protect
	
	def overview
  	session[:return_to] = nil
  	
  	load_my_recipes
  	@recipes = @recipes_set[0..MATRIX_ITEMS_COUNT_PER_PAGE_S - 1]
  	
  	load_my_reviews
  	@reviews = @reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
	 	
	 	info = "我的#{SITE_NAME_CN}"
		set_page_title(info)
		
		@user = @current_user
		@show_todo = true
		
		store_location
		
		render :template => "users/overview"
	end
	
	def recipes
		session[:return_to] = nil
    
		load_my_recipes
		items_paginate(@recipes_set)
	 	@recipes = @items
 																 		 
 		info = "我的#{RECIPE_CN} (#{@recipes_set_count})"
 		@recipes_html_id_suffix = "user_#{@current_user.id}"
 		
 		@show_header_link = true
 		@show_photo_todo = true
  	@show_todo = true
  	
  	@recipes_html_id = "recipes_of_#{@recipes_html_id_suffix}"
  	
		set_page_title(info)
		set_block_title(info)
		
		store_location
		
		render :template => "recipes/index"	
	end
	
	def reviews
		session[:return_to] = nil
		
    if params[:reviewable_type]
    	@reviewable_type = params[:reviewable_type].downcase
    	@reviews_html_id_prefix = @reviewable_type
    else
    	@reviews_html_id_prefix = 'all'
    end
    
		load_my_reviews
		items_paginate(@reviews_set)
	 	@reviews = @items
 																 		 
 		info = "我的#{name_for(@reviewable_type)}#{REVIEW_CN} (#{@reviews_set_count})"
 		@reviews_html_id_suffix = "user_#{@current_user.id}"
 		
  	@show_todo = true
  	
  	@reviews_html_id = "#{@reviews_html_id_prefix}_reviews_of_#{@reviews_html_id_suffix}"
  	
		set_page_title(info)
		set_block_title(info)
		
 		if @reviewable_type
 			session[:return_to] = "#{user_reviews_path(@current_user)}?reviewable_type=#{@reviewable_type}"
 		else
 			session[:return_to] = user_reviews_path(@current_user)
 		end
		
		render :template => "reviews/index"
	end
	
	private
	
	def load_my_recipes
		@recipes_set = recipes_for(@current_user, nil, nil, nil, 'created_at DESC')
		@recipes_set_count = @recipes_set.size
	end
	
	def load_my_reviews
		@reviews_set = reviews_for(@current_user, @reviewable_type, nil, nil, nil, 'created_at DESC')
		@reviews_set_count = @reviews_set.size
	end

end
