class FavoritesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	before_filter :load_favorable_type, :only => [:index, :mine]
	before_filter :load_back_to_type, :except => [:index, :show]
	
	def index
		respond_to do |format|
			if @user
		  	if @user == @current_user
	      	if params[:favorable_type]
	      		format.html { redirect_to :action => 'mine', :favorable_type => @favorable_type.downcase }
	      	else
	      		format.html { redirect_to :action => 'mine' }
	      	end
		  	else
			    load_favorites_set(@user)
			    load_favorables_set
			    
			    info = "#{username_prefix(@user)}#{name_for(params[:favorable_type])}#{FAVORITE_CN} (#{@favorites_set_count})"
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
		      															 :back_to_type => @back_to_type }
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
		      															 :back_to_type => @back_to_type }
					page.show "overlay"
				end
			end
  	end
	end
	
	def create
		if @current_user && @parent_obj.user != @current_user
			@favorite = @parent_obj.favorites.build(params[:favorite])
			@favorite.user_id = @current_user.id
			@favorite.status = params[:status].values.join(' ')
			
			if @favorite.save
				@notice = "你已经成功#{ADD_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
				after_save_ok
			else
				after_save_error
			end
		end
	end
	
	def update
		if @current_user && @parent_obj.user != @current_user
	    load_favorite(@current_user)
			params[:favorite][:status] = params[:status].values.join(' ')
			
			if @favorite.update_attributes(params[:favorite])
				@notice = "你已经成功#{UPDATE_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
				after_save_ok
			else
				after_save_error
			end
		end
	end
	
	def destroy
		if @current_user && @parent_obj.user != @current_user
			load_favorite
			
			if @favorite.destroy
				@notice = "你已经成功#{DELETE_CN}了1个#{@parent_name}#{FAVORITE_CN}!"
				after_destroy_ok
			end
		end
	end
	
	def mine
    load_favorites_set(@current_user)
    load_favorables_set
		
  	info = "#{username_prefix(@current_user)}#{name_for(params[:favorable_type])}#{FAVORITE_CN} (#{@favorites_set_count})"
		set_page_title(info)
		set_block_title(info)
		
		@show_todo = true
		@show_favorite = true
		
    respond_to do |format|
      format.html { render :template => "/#{controller_name(@favorable_type)}/index" }
    end
	end
	
	private
	
	def load_back_to_type
		@back_to_type = params[:back_to_type]
	end
	
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
  	favorite_conditions = favorite_conditions(@favorable_type, @parent_id)
  	if @favorable_type == 'Recipe'
	 		favorable_conditions = recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user))
	 	end
 		@favorites_set = favorites_for(user, @favorable_type, favorite_conditions, favorable_conditions)
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
	
	def after_save_ok
		respond_to do |format|
			format.js do
				render :update do |page|
					page.hide "overlay"
					page.replace_html "flash_wrapper", 
														:partial => "/layouts/flash",
												 		:locals => { :notice => @notice }
					page.show "flash_wrapper"
					page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
														:partial => '/favorites/favorite_bar', 
														:locals => { :favorable => @parent_obj, 
																				 :back_to_type => @back_to_type }
					if @back_to_type == 'index'
						page.replace_html "#{@parent_type.downcase}_#{@parent_id}_stats",
															:partial => "/#{controller_name(@parent_type)}/#{@parent_type.downcase}_stats", 
									 						:locals => { :item => @parent_obj }
					end
					# page.visual_effect :highlight, "#{@parent_type.downcase}_#{@parent_id}_favorite", :duration => 3
				end
			end
		end
	end
	
	def after_save_error
		respond_to do |format|
			format.js do
				render :update do |page|
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
								 												 :back_to_type => @back_to_type }
					# page.visual_effect :fade, "notice_for_favorite", :duration => 3
				end
			end
		end
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.js do
				render :update do |page|
					if @back_to_type == 'mine'
						flash[:notice] = @notice
						page.redirect_to ''
					else
						page.replace_html "flash_wrapper", 
															:partial => "/layouts/flash",
													 		:locals => { :notice => @notice }
						page.show "flash_wrapper"
						page.replace_html "#{@parent_type.downcase}_#{@parent_id}_favorite", 
															:partial => '/favorites/favorite_bar', 
															:locals => { :favorable => @parent_obj, 
																					 :back_to_type => @back_to_type }
						if @back_to_type == 'index'
							page.replace_html "#{@parent_type.downcase}_#{@parent_id}_stats",
																:partial => "/#{controller_name(@parent_type)}/#{@parent_type.downcase}_stats", 
										 						:locals => { :item => @parent_obj }
						end
					end
					# page.visual_effect :highlight, "#{@parent_type.downcase}_#{@parent_id}_favorite", :duration => 3
				end
			end
		end
	end

end
