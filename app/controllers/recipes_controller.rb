class RecipesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show, :overview]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview]
	before_filter :set_system_notice, :only => [:overview]
	
#	def change_from_type
#  	respond_to do |format|
#			format.js do
#				render :update do |page|
#					if params[:from_type] == '1'
#						page.hide "from_where_wrapper"
#						page.hide "from_where_errors"
#						page.replace_html "from_where_wrapper",
#															:partial => 'layouts/item_from_where',
#                              :locals => { :item_type => 'recipe' }
#					else
#						page.replace_html "from_where_wrapper",
#															:partial => 'layouts/item_from_where',
#                              :locals => { :item_type => 'recipe' }
#						page.show "from_where_wrapper"
#					end
#				end
#			end
#  	end
#	end
	
  # GET /recipes
  # GET /recipes.xml
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => params[:filter] }
      else
		    load_recipes_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{RECIPE_CN}"
				set_page_title(info)
				set_block_title(info)
				
		  	@show_todo = true
		  	@show_favorite = true
				
      	format.html
      end
      # format.xml  { render :xml => @recipes_set }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
		load_recipe
			
		load_recipes_set(@recipe.user)
		
		@recipe_index = @recipes_set.index(@recipe)
		
		recipe = [@recipe]
		@other_recipes_set = @recipes_set - recipe
		recipes_conditions = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
		related_recipes_conditions = recipes_conditions
		@related_recipes_set = taggables_for(nil, 'Recipe', @recipe.tag_list, related_recipes_conditions, nil, nil, nil, 'RAND()') - recipe
		same_title_recipes_conditions_list = [ "recipes.title = '#{@recipe.title}'", "recipes.common_title = '#{@recipe.title}'" ]
		if (common_title = @recipe.common_title) && !common_title.blank?
			same_title_recipes_conditions_list += [ "recipes.common_title = '#{common_title}'", "recipes.title = '#{common_title}'" ]
		end
		same_title_recipes_conditions = "#{recipes_conditions} AND (#{same_title_recipes_conditions_list.join(' OR ')})"
		@same_title_recipes_set = recipes_for(nil, same_title_recipes_conditions, nil, 'RAND()') - recipe
		@same_title_recipes_set_count = @same_title_recipes_set.size
		@favorite_users_set = favorite_users(@recipe.favorites.find(:all, :limit => 12, :order => 'RAND()'))
		@favorite_users_set_count = @favorite_users_set.size
		@entried_matches_set = entried_matches(@recipe.entries.find(:all, :limit => 12, :order => 'RAND()'))
		
		current = Time.now
		if @recipe.match_id && (@match = Match.find_by_id_and_entriable_type(@recipe.match_id, 'Recipe')) && @match.doing?(current)
			@entry = @match.find_entry(@recipe)
		end											
		
		show_sidebar
		
		recipe_title = item_title(@recipe)
		recipe_common_title = @recipe.common_title.strip if !@recipe.common_title.blank?
		recipe_username = user_username(@recipe.user, true, true)
		recipe_link_url = item_first_link(@recipe)
		
		info = "#{RECIPE_CN} - #{recipe_title}"
		set_page_title(info)
		set_block_title(info)
		@meta_description = "这是#{recipe_title}#{add_brackets(recipe_common_title, '(', ')')}的#{RECIPE_CN}信息, 来自#{recipe_username}. "
		@meta_keywords = default_meta_keywords('Recipe')
		@meta_keywords = [recipe_common_title] + @meta_keywords if !recipe_common_title.blank?
		@meta_keywords = [ recipe_title, recipe_username, recipe_link_url ] + @meta_keywords
		@meta_keywords << @recipe.tag_list if !@recipe.tag_list.blank?
																							 
    respond_to do |format|
      format.html do
      	log_count(@recipe)
      end
      # format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/new
  # GET /recipes/new.xml
  def new
    @recipe = @current_user.recipes.build
		@recipe.is_draft = '1'
		
		# load_recipes_set(@current_user)
    
    info = "新#{RECIPE_CN}"
		set_page_title(info)
		set_block_title(info)
    
    respond_to do |format|
      format.html
      # format.xml  { render :xml => @recipe }
    end
    
  end

  # GET /recipes/1/edit
  def edit
    load_recipe(@current_user)
    
    # load_recipes_set(@current_user)
    
 		info = "#{EDIT_CN}#{RECIPE_CN} - #{item_title(@recipe)}"
		set_page_title(info)
		set_block_title(info)
		
		respond_to do |format|
			format.html
		end
  end

  # POST /recipes
  # POST /recipes.xml
  def create
  	set_tag_list

    @recipe = @current_user.recipes.build(params[:recipe])
    @recipe.status = @recipe.get_status
    item_client_ip(@recipe)
    # @recipe.is_draft = params[:is_draft]
    # @recipe.is_draft = @recipe.get_is_draft
    # @recipe.published_at = @recipe.get_published_at
    
    ActiveRecord::Base.transaction do    
			if @recipe.save
				# @recipe.tag_list = params[:tags].strip if params[:tags] && !params[:tags].strip.blank?
				reg_homepage(@recipe)
				after_create_ok
			else
				after_create_error
			end
		end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    load_recipe(@current_user)
    new_recipe = @current_user.recipes.build(params[:recipe])
    # new_recipe.cover_photo_id = @recipe.cover_photo_id
    # new_recipe.published_at = @recipe.published_at
    # new_recipe.status = new_recipe.get_status
    # new_recipe.is_draft = new_recipe.get_is_draft
    # new_recipe.published_at = new_recipe.get_published_at
    
    # params[:recipe][:status] = new_recipe.status
    # params[:recipe][:is_draft] = new_recipe.is_draft
    # params[:recipe][:published_at] = new_recipe.published_at
    params[:recipe][:original_updated_at] = Time.now
    params[:recipe][:status] = new_recipe.get_status
		
		set_tag_list
    
    ActiveRecord::Base.transaction do
		  if @recipe.update_attributes(params[:recipe])
		  	# @recipe.tag_list = params[:tags].strip if params[:tags] && params[:tags].strip != @recipe.tag_list
				reg_homepage(@recipe, 'update')
				after_update_ok
		  else
				after_update_error
		  end
	  end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    load_recipe(@current_user)
		
		if !@recipe.entrying?
			ActiveRecord::Base.transaction do
				if @recipe.destroy
					reg_homepage(@recipe, 'destroy')
					after_destroy_ok
				end
			end
		end
  end
  
  # 发布
  def publish
  	load_recipe(@current_user)
  	# if !@recipe.entrying?
	  #   if params[:to_publish]
		#     @recipe.is_draft = '0'
		#     @recipe.published_at = @recipe.get_published_at
		# 		@notice = "你已经发布了1#{@self_unit}#{@self_name}!"
		#   else
		#   	@recipe.is_draft = '1'
		# 		@notice = "你已经将1#{@self_unit}#{@self_name}设置为草稿!"
		#   end
	  	
		# 	if Recipe.update(@recipe.id, { :is_draft => @recipe.is_draft, :published_at => @recipe.published_at, :original_updated_at => Time.now })
		
		if @recipe.publishable?
			current = Time.now
			new_attrs = { :is_draft => '0', :published_at => current, :original_updated_at => current }
			@notice = "你已经发布了1#{@self_unit}#{@self_name}!"
			
			if @recipe.update_attributes(new_attrs)
				reg_homepage(@recipe, 'update')
				after_publish_ok
			end
		end
  end
  
#  # 精选
#	def choice
#		if @current_user && @current_user.is_role_of?('admin')
#			load_recipe
#			respond_to do |format|
#				format.html do
#					current_roles = @recipe.roles || ''
#
#			    if params[:to_choice]
#						new_roles = current_roles + ' 11'
#						@notice = "你已经#{ADD_CN}了1#{@self_unit}精选#{@self_name}!"
#				  else
#				  	new_roles = current_roles.gsub('11', '')
#						@notice = "你已经将1#{@self_unit}#{@self_name}从精选#{@self_name}中#{DELETE_CN}了!"
#				  end
#
#				  new_roles = new_roles.strip.gsub(/\s+/, ' ')
#
#					if @recipe.update_attribute(:roles, new_roles)
#						after_choice_ok
#					end
#				end
#			end
#		end
#	end
	
	#分享
	def share
    load_recipe
    
 		info = "分享#{RECIPE_CN} - #{@recipe.title}"
		set_page_title(info)
		set_block_title(info)
	end
  
  def overview
	  load_recipes_set
	  load_random_recipes
	  load_choice_recipes
	  load_reviews_set
	  load_tags_set
	  
  	ranked_recipes_set = highest_rated_items(@recipes_set)[0..99]
  	if ranked_recipes_set
	  	@highlighted_recipe = ranked_recipes_set.rand
	  	if @highlighted_recipe_rank = ranked_recipes_set.index(@highlighted_recipe)
	  		@highlighted_recipe_rank += 1
	  	end
	  	@highest_rated_recipes = ranked_recipes_set[0..19]
	  end
  	# @random_recipes = random_items(@recipes_set, 12)
	  
	  info = RECIPE_CN
		set_page_title(info)
		
		show_sidebar
  end
  
  def mine
  	@order = 'created_at DESC, published_at DESC'
    load_recipes_set(@current_user)
    
  	@show_photo_todo = true
  	@show_todo = true
  	@show_manage = true
		
		info = "#{username_prefix(@current_user)}#{RECIPE_CN}"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "recipes/index" }
      # format.xml  { render :xml => @recipes_set }
    end
  end
  
  private
  
  def set_tag_list
    if !params[:recipe][:tag_list].strip.blank?
    	params[:recipe][:tag_list] = clean_tags(params[:recipe][:tag_list])
    end
  end
  
  def load_recipe(user = nil)
  	if user
 			recipe = user.recipes.find(@self_id)
 		else
 			recipe = Recipe.find(@self_id)
 		end
 		if params[:action] == 'destroy' || recipe_accessible?(recipe)
 			@recipe = recipe
 		end
  end
  
  def load_recipes_set(user = nil)
  	order = @order ? @order : 'published_at DESC, created_at DESC'
  	@recipes_set = filtered_recipes(user, params[:filter], nil, order)
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_choice_recipes(user = nil)
  	@choice_recipes = roles_recipes(user, '11', 12)
  end
  
  def load_random_recipes(user = nil)
  	@random_recipes = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 12, 'RAND()')
  end
  
  def load_reviews_set(user = nil)
  	# @reviews_set = reviews_for(user, 'Recipe', review_conditions('Recipe', @self_id), recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)))
  	@reviews_set = reviewable_type_reviews('Recipe')[0..19]
  	@reviews_set_count = @reviews_set.size
  end
  
  def load_tags_set(user = nil)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
  	@tags_set_count = @tags_set.size
  end
  
  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}, 快去#{ADD_CN}几#{unit_for('Photo')}#{PHOTO_CN}吧!"	
				redirect_to @recipe
			end
			# format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
			format.js do
				render @recipe
			end
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
#				load_recipes_set(@current_user)
				
				info = "新#{RECIPE_CN}"	
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			# format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
		end
  end
  
  def after_update_ok
  	respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"	
				redirect_to @recipe
			end
			# format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"			
				
#				load_recipes_set(@current_user)
				
				info = "#{EDIT_CN}#{RECIPE_CN} - #{item_title(@recipe)}"
				set_page_title(info)
				set_block_title(info)				
				
				render :action => "edit"
				clear_notice
			end
			# format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
		end
  end
  
  def after_destroy_ok
		respond_to do |format|
		  format.html do
		  	flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"	
		  	# redirect_back_or_default('mine')
		  	redirect_to url_for(:controller => 'recipes', :action => 'mine', :filter => params[:filter], :page => params[:page])
		  end
		  # format.xml  { head :ok }
		end
  end
  
  def after_publish_ok
  	respond_to do |format|
  		format.html do
  			flash[:notice] = @notice	
  			redirect_back_or_default('mine')
  		end
			format.js do
				render :update do |page|
					case params[:ref]
					when 'show'
						page.replace_html "flash_wrapper", 
															:partial => "/layouts/flash", 
															:locals => { :notice => @notice }
						page.replace_html "recipe_#{@recipe.id}_title",
															:partial => "/layouts/item_basic", 
															:locals => { :item => @recipe,
									 												 :show_icon => true,
									 												 :show_title => true,
									 												 :show_link => true }
						page.replace_html "recipe_#{@recipe.id}_manage",
															:partial => "/recipes/recipe_manage", 
															:locals => { :item => @recipe, 
										 											 :ref => 'show', 
										 											 :delete_remote => false }
					when 'index'
		  			flash[:notice] = @notice	
		  			page.redirect_to :action => 'mine', :filter => params[:filter]
					end
				end
			end
  	end
  end
  
#  def after_choice_ok
#  	respond_to do |format|
#  		format.js do
#  			render :update do |page|
#					page.replace_html "flash_wrapper",
#														:partial => "/layouts/flash",
#														:locals => { :notice => @notice }
#					page.replace_html "recipe_#{@recipe.id}_title",
#														:partial => "/layouts/item_basic",
#														:locals => { :item => @recipe,
#								 												 :show_icon => true,
#								 												 :show_title => true,
#								 												 :show_link => true }
#					page.replace_html "recipe_#{@recipe.id}_admin",
#														:partial => "/system/item_admin_bar",
#														:locals => { :item => @recipe,
#									 											 :ref => 'show' }
#  			end
#  		end
#  	end
#  end
  
end
