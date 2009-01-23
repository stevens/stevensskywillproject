class FavoritesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	before_filter :load_favorable_type, :only => [:index, :mine]
	
	def index
		respond_to do |format|
			if @user
		  	if @user == @current_user
	      	if params[:favorable_type]
	      		format.html { redirect_to :action => 'mine', :favorable_type => params[:favorable_type], :filter => params[:filter] }
	      	else
	      	 	format.html { redirect_to :action => 'mine', :filter => params[:filter] }
	      	end
		  	else
			    load_favorites_set(@user)
			    load_favorables_set
			    
			    info = "#{username_prefix(@user)}#{name_for(params[:favorable_type])}#{FAVORITE_CN}"
			    set_page_title(info)
			    set_block_title(info)
			    
			    @show_todo = true
					@show_favorite = true
					
					format.html { render :template => "/#{controller_name(@favorable_type)}/index" }
		  	end
		  elsif @parent_obj
		  	load_favorites_set
		  end 	
    end
	end
	
	def show
	
	end
	
	def new
  	respond_to do |format|
  		format.html { redirect_to @parent_obj }
			format.js do
				@favorite = @parent_obj.favorites.build
				render :update do |page|
		      page.replace_html "overlay", 
		      									:partial => "/favorites/favorite_overlay", 
		      									:locals => { :favorable => @parent_obj, 
		      															 :favorite => @favorite, 
		      															 :is_new => true, 
		      															 :current_status => nil, 
		      															 :favorable_type => params[:favorable_type], 
		      															 :filter => params[:filter], 
		      															 :ref => params[:ref], 
		      															 :favoriter_id => params[:favoriter_id] }
					page.show "overlay"
				end
			end
  	end
	end
	
	def edit
  	respond_to do |format|
			format.js do
				load_favorite(@current_user)
				render :update do |page|
		      page.replace_html "overlay", 
		      									:partial => "/favorites/favorite_overlay", 
		      									:locals => { :favorable => @parent_obj, 
		      															 :favorite => @favorite, 
		      															 :is_new => false, 
		      															 :current_status => @favorite.status, 
		      															 :favorable_type => params[:favorable_type], 
		      															 :filter => params[:filter], 
		      															 :ref => params[:ref],
		      															 :favoriter_id => params[:favoriter_id] }
					page.show "overlay"
				end
			end
  	end
	end
	
	def create
		if @current_user && @parent_obj.user != @current_user
			unless @parent_obj.favorites.find(:first, :conditions => { :user_id => @current_user.id })
				@favorite = @parent_obj.favorites.build(params[:favorite])
				@favorite.user_id = @current_user.id
				@favorite.status = params[:status].values.join(' ')
				
				if @favorite.save
					@notice = "你已经#{ADD_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
					after_todo_ok('create')
				else
					after_todo_error('create')
				end
			end
		end
	end
	
	def update
		if @current_user && @parent_obj.user != @current_user
	    load_favorite(@current_user)
			params[:favorite][:status] = params[:status].values.join(' ')
			
			if @favorite.update_attributes(params[:favorite])
				@notice = "你已经#{UPDATE_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
				after_todo_ok('update')
			else
				after_todo_error('update')
			end
		end
	end
	
	def destroy
		if @current_user && @parent_obj.user != @current_user
			load_favorite
			
			if @favorite.destroy
				@notice = "你已经#{DELETE_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
				after_todo_ok('destroy')
			end
		end
	end
	
	def mine
    load_favorites_set(@current_user)
    load_favorables_set
		
  	info = "#{username_prefix(@current_user)}#{name_for(params[:favorable_type])}#{FAVORITE_CN}"
		set_page_title(info)
		set_block_title(info)
		
		@show_todo = true
		@show_favorite = true
		
    respond_to do |format|
      format.html { render :template => "/#{controller_name(@favorable_type)}/index" }
    end
	end
	
	private
	
	def load_favorable_type
		if @parent_type
			@favorable_type = @parent_type
		elsif params[:favorable_type]
			@favorable_type = params[:favorable_type].camelize
		else
			@favorable_type = 'Recipe'
		end
	end
	
  def load_favorite(user = nil)
 		if user
 			@favorite = user.favorites.find(@self_id)
 		else
 			@favorite = Favorite.find(@self_id)
 		end
  end
  
  def load_favorites_set(user = nil)
  	# favorite_conditions = favorite_conditions(@favorable_type)
  	# if @favorable_type == 'Recipe'
	 	# 	favorable_conditions = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
	 	# end
 		# @favorites_set = favorites_for(user, @favorable_type, favorite_conditions, favorable_conditions)
  	
  	favorable_type = @favorable_type || 'Recipe'
		@favorites_set = filtered_favorites(user, favorable_type, params[:filter])
  	@favorites_set_count = @favorites_set.size
  end
  
  def load_favorables_set
  	if @favorable_type && @favorites_set
  		if @favorable_type == 'Recipe'
  			@recipes_set = []
  			for favorite in @favorites_set
  				@recipes_set << favorite.favorable
  			end
  			@recipes_set_count = @recipes_set.size
  		end
  	end
  end
  
  def page_update_flash_notice
		@page.replace_html "flash_wrapper", 
											:partial => "/layouts/flash",
									 		:locals => { :notice => @notice }
		@page.show "flash_wrapper"  
  end
  
  def page_update_favorite_bar
		@page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
											:partial => '/favorites/favorite_bar', 
											:locals => { :favorable => @parent_obj,
																	 :ref => params[:ref], 
																	 :favoriter_id => params[:favoriter_id] }
  end
  
  def page_update_favorable_stats
		@page.replace_html "#{@parent_type.downcase}_#{@parent_id}_stats",
											:partial => "/#{controller_name(@parent_type)}/#{@parent_type.downcase}_stats", 
					 						:locals => { :item => @parent_obj }
  end
  
  def page_update_favorite_users
		@page.replace_html "favorite_users_detail", 
											:partial => "/layouts/items_matrix",
										  :locals => { :show_paginate => false,
										 						   :items_set => favorite_users(@parent_obj.favorites.find(:all, :limit => 12, :order => 'RAND()')), 
										 						   :limit => 12,
										 						   :items_count_per_row => 4,  
										 						   :show_photo => true, 
										 						   :show_below_photo => false,  
										 						   :show_title => false, 
										 						   :show_user => false, 
										 						   :show_photo_todo => false, 
										 						   :photo_style => 'sign' }
  end
  
  def page_update_my_favorites_list
		flash[:notice] = @notice
		@page.redirect_to :controller => 'favorites', :action => 'mine', :favorable_type => params[:favorable_type], :filter => params[:filter]
  end
  
  def after_todo_ok(name)
  	respond_to do |format|
			format.js do
				render :update do |page|
			  	if params[:ref] != 'my_favorables_list'
			  		page.hide "overlay" if name != 'destroy'
						page.replace_html "flash_wrapper", 
															:partial => "/layouts/flash",
													 		:locals => { :notice => @notice }
						page.show "flash_wrapper"
			  		# page_update_flash_notice
			  		
						case name
						when 'create'
							if params[:ref] != 'my_favorites_list'
								page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
																	:partial => '/favorites/favorite_bar', 
																	:locals => { :favorable => @parent_obj,
																							 :ref => params[:ref], 
																							 :favoriter_id => params[:favoriter_id] }
								if params[:ref] == 'favorable_show'
									page.replace_html "favorite_users_detail", 
																		:partial => "/layouts/items_matrix",
																	  :locals => { :show_paginate => false,
																	 						   :items_set => favorite_users(@parent_obj.favorites.find(:all, :limit => 12, :order => 'RAND()')), 
																	 						   :limit => 12,
																	 						   :items_count_per_row => 4,  
																	 						   :show_photo => true, 
																	 						   :show_below_photo => false,  
																	 						   :show_title => false, 
																	 						   :show_user => false, 
																	 						   :show_photo_todo => false, 
																	 						   :photo_style => 'sign' }
									page.replace "stats_entry_of_favorite",
															 :partial => 'layouts/stats_entry', 
												 			 :locals => { :stats_entry => [ 'favorite', @parent_obj.favorites.size, '人', FAVORITE_CN ] }
								else
									page.replace "stats_entry_of_#{@parent_type.downcase}_#{@parent_id}_favorite_s",
															 :partial => 'layouts/stats_entry_s', 
															 :locals => { :stats_entry => [ [ 'favorite', @parent_type, @parent_id ], [ @parent_obj.favorites.size, '人', FAVORITE_CN ] ] }
								end

								# page_update_favorite_bar
								# page_update_favorable_stats
								# page_update_favorite_users if params[:ref] == 'favorable_show'
							end
						when 'update'
							if params[:ref] == 'my_favorites_list'
								flash[:notice] = @notice
								if params[:favorable_type]
									page.redirect_to :controller => 'favorites', :action => 'mine', :favorable_type => params[:favorable_type], :filter => params[:filter]
								else
									page.redirect_to :controller => 'favorites', :action => 'mine', :filter => params[:filter]
								end
								# page_update_my_favorites_list
							else
								page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
																	:partial => '/favorites/favorite_bar', 
																	:locals => { :favorable => @parent_obj,
																							 :ref => params[:ref], 
																							 :favoriter_id => params[:favoriter_id] }
								# page_update_favorite_bar
							end
						when 'destroy'
							if params[:ref] == 'my_favorites_list'
								flash[:notice] = @notice
								if params[:favorable_type]
									page.redirect_to :controller => 'favorites', :action => 'mine', :favorable_type => params[:favorable_type], :filter => params[:filter]
								else
									page.redirect_to :controller => 'favorites', :action => 'mine', :filter => params[:filter]
								end
								# page_update_my_favorites_list
							else
								page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
																	:partial => '/favorites/favorite_bar', 
																	:locals => { :favorable => @parent_obj,
																							 :ref => params[:ref], 
																							 :favoriter_id => params[:favoriter_id] }
								if params[:ref] == 'favorable_show'
									page.replace_html "favorite_users_detail", 
																		:partial => "/layouts/items_matrix",
																	  :locals => { :show_paginate => false,
																	 						   :items_set => favorite_users(@parent_obj.favorites.find(:all, :limit => 12, :order => 'RAND()')), 
																	 						   :limit => 12,
																	 						   :items_count_per_row => 4,  
																	 						   :show_photo => true, 
																	 						   :show_below_photo => false,  
																	 						   :show_title => false, 
																	 						   :show_user => false, 
																	 						   :show_photo_todo => false, 
																	 						   :photo_style => 'sign' }
									page.replace "stats_entry_of_favorite",
															 :partial => 'layouts/stats_entry', 
									 						 :locals => { :stats_entry => [ 'favorite', @parent_obj.favorites.size, '人', FAVORITE_CN ] }
								else
									page.replace "stats_entry_of_#{@parent_type.downcase}_#{@parent_id}_favorite_s",
															 :partial => 'layouts/stats_entry_s', 
															 :locals => { :stats_entry => [ [ 'favorite', @parent_type, @parent_id ], [ @parent_obj.favorites.size, '人', FAVORITE_CN ] ] }
								end
								# page_update_favorite_bar
								# page_update_favorable_stats
								# page_update_favorite_users if params[:ref] == 'favorable_show'
							end
						end
						
					end
				end
			end
		end
  end
  
  def after_todo_error(name)
		respond_to do |format|
			format.js do
				render :update do |page|
					if name == 'create' || name == 'update'
						page.replace_html "notice_for_favorite", 
															:partial => '/layouts/notice', 
															:locals => { :notice => "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!" }
						page.show "notice_for_favorite"
						page.replace_html "input_form_for_favorite",
															:partial => "/favorites/favorite_input",
														  :locals => { :favorable => @favorite.favorable, 
									 												 :favorite => @favorite, 
									 												 :is_new => true, 
									 												 :current_status => @favorite.status, 
														 							 :favorable_type => params[:favorable_type], 
														 							 :filter => params[:filter], 
									 												 :ref => params[:ref],
									 												 :favoriter_id => params[:favoriter_id] }
						# page.visual_effect :fade, "notice_for_favorite", :duration => 3
					end
				end
			end
		end
  end

end
