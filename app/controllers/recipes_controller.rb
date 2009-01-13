class RecipesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show, :overview]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview]
	before_filter :load_current_filter, :only => [:index, :mine]
	# before_filter :set_system_notice, :only => [:show, :new, :edit]
	
	def change_from_type
  	respond_to do |format|
			format.js do
				render :update do |page|
					if params[:from_type] == '1'
						page.hide "from_where_wrapper"
						page.hide "from_where_errors"
						page.replace_html "from_where_wrapper",
															:partial => '/recipes/recipe_from_where'
					else
						page.replace_html "from_where_wrapper",
															:partial => '/recipes/recipe_from_where'
						page.show "from_where_wrapper"
					end
				end
			end
  	end
	end
	
  # GET /recipes
  # GET /recipes.xml
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => @current_filter }
      else
		    load_recipes_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{RECIPE_CN}"
				set_page_title(info)
				set_block_title(info)
				
		  	@show_todo = true
		  	@show_favorite = true
				
      	format.html # index.html.erb
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
		same_title_recipes_conditions = [recipes_conditions]
		same_title_recipes_conditions << "recipes.title LIKE '%#{@recipe.title}%'"
		@same_title_recipes_set = recipes_for(nil, same_title_recipes_conditions.join(' AND '), nil, 'RAND()') - recipe
		@same_title_recipes_set_count = @same_title_recipes_set.size
		@favorite_users_set = favorite_users(@recipe.favorites.find(:all, :limit => 12, :order => 'RAND()'))
		@favorite_users_set_count = @favorite_users_set.size
		@entried_matches_set = entried_matches(@recipe.entries.find(:all, :limit => 12, :order => 'RAND()'))
		
		current = Time.now
		if @recipe.match_id && (@match = Match.find_by_id_and_entriable_type(@recipe.match_id, 'Recipe')) && @match.doing?(current)
			@entry = @match.find_entry(@recipe)
		end
		
    log_count(@recipe)												
		
		show_sidebar
		
		info = "#{RECIPE_CN} - #{@recipe.title}"
		set_page_title(info)
		set_block_title(info)
		@meta_description = "这是#{@recipe.title}的#{RECIPE_CN}（菜谱）信息, 来自#{@recipe.user.login}. "
		@meta_keywords = [@recipe.title, @recipe.user.login, DESCRIPTION_CN, INGREDIENT_CN, DIRECTION_CN, TIP_CN]
		@meta_keywords << @recipe.tag_list
																							 
    respond_to do |format|
      format.html # show.html.erb
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
      format.html # new.html.erb
      # format.xml  { render :xml => @recipe }
    end
    
  end

  # GET /recipes/1/edit
  def edit
    load_recipe(@current_user)
    
    # load_recipes_set(@current_user)
    
 		info = "#{EDIT_CN}#{RECIPE_CN} - #{@recipe.title}"
		set_page_title(info)
		set_block_title(info)
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    @recipe = @current_user.recipes.build(params[:recipe])
    @recipe.status = @recipe.get_status
    @recipe.is_draft = @recipe.get_is_draft
    @recipe.published_at = @recipe.get_published_at
    
		if @recipe.save
			@recipe.tag_list = params[:tags].strip if params[:tags] && !params[:tags].strip.blank?
			reg_homepage(@recipe)
			after_create_ok
		else
			after_create_error
		end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    load_recipe(@current_user)
    new_recipe = @current_user.recipes.build(params[:recipe])
    new_recipe.cover_photo_id = @recipe.cover_photo_id
    new_recipe.published_at = @recipe.published_at
    new_recipe.status = new_recipe.get_status
    new_recipe.is_draft = new_recipe.get_is_draft
    new_recipe.published_at = new_recipe.get_published_at
    
    params[:recipe][:status] = new_recipe.status
    params[:recipe][:is_draft] = new_recipe.is_draft
    params[:recipe][:published_at] = new_recipe.published_at
    params[:recipe][:original_updated_at] = Time.now
    
	  if @recipe.update_attributes(params[:recipe])
	  	@recipe.tag_list = params[:tags].strip if params[:tags] && params[:tags].strip != @recipe.tag_list
			reg_homepage(@recipe, 'update')
			after_update_ok
	  else
			after_update_error
	  end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    load_recipe(@current_user)
		
		if !@recipe.entrying?
			@recipe.destroy
			reg_homepage(@recipe, 'destroy')
			after_destroy_ok
		end
  end
  
  # 发布
  def publish
  	load_recipe(@current_user)
  	if !@recipe.entrying?
	    if params[:to_publish]
		    @recipe.is_draft = '0'
		    @recipe.published_at = @recipe.get_published_at
				@notice = "你已经发布了1#{@self_unit}#{@self_name}!"
		  else
		  	@recipe.is_draft = '1'
				@notice = "你已经将1#{@self_unit}#{@self_name}设置为草稿!"
		  end
	  	
			if Recipe.update(@recipe.id, { :is_draft => @recipe.is_draft, :published_at => @recipe.published_at, :original_updated_at => Time.now })
				reg_homepage(@recipe, 'update')
				after_publish_ok
			end
		end
  end
  
  # 精选
	def choice
		if @current_user && @current_user.is_role_of?('admin')
			load_recipe
			respond_to do |format|
				format.html do
					current_roles = @recipe.roles || ''
					
			    if params[:to_choice]
						new_roles = current_roles + ' 11'
						@notice = "你已经#{ADD_CN}了1#{@self_unit}精选#{@self_name}!"
				  else
				  	new_roles = current_roles.gsub('11', '')
						@notice = "你已经将1#{@self_unit}#{@self_name}从精选#{@self_name}中#{DELETE_CN}了!"
				  end
				  
				  new_roles = new_roles.strip.gsub(/\s+/, ' ')
					
					if @recipe.update_attribute(:roles, new_roles)
						after_choice_ok
					end
				end
			end
		end
	end
  
  # /recipes/overview
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
	  	@highest_rated_recipes = ranked_recipes_set[0..9]
	  end
  	# @random_recipes = random_items(@recipes_set, 12)
	  
	  info = RECIPE_CN
		set_page_title(info)
		
		show_sidebar
  end
  
  def mine
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
  
	def set_system_notice
		# @system_notice = "号外: 提供食谱的<em>蜂友的blog</em>可以<em>自动加入</em>食谱的<em>相关链接</em>啦!"
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
  	@recipes_set = filtered_recipes(user, @current_filter)
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_choice_recipes(user = nil)
  	@choice_recipes = roles_recipes(user, '11', 12)
  end
  
  def load_random_recipes(user = nil)
  	@random_recipes = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 12, 'RAND()')
  end
  
  def load_reviews_set(user = nil)
  	@reviews_set = reviews_for(user, 'Recipe', review_conditions('Recipe', @self_id), recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)))
  	@reviews_set_count = @reviews_set.size
  end
  
  def load_tags_set(user = nil)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
  	@tags_set_count = @tags_set.size
  end
  
  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}!"	
				redirect_to @recipe
			end
			format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
			format.js do
				render @recipe
			end
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				load_recipes_set(@current_user)
				
				info = "新#{RECIPE_CN}"	
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
		end
  end
  
  def after_update_ok
  	respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"	
				redirect_to @recipe
			end
			format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"			
				
				load_recipes_set(@current_user)
				
				info = "#{EDIT_CN}#{RECIPE_CN} - #{@recipe.title}"
				set_page_title(info)
				set_block_title(info)				
				
				render :action => "edit"
				clear_notice
			end
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
		end
  end
  
  def after_destroy_ok
		respond_to do |format|
		  format.html do
		  	flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"	
		  	redirect_back_or_default('mine')
		  end
		  format.xml  { head :ok }
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
  
  def after_choice_ok
  	respond_to do |format|
  		format.js do
  			render :update do |page|
					page.replace_html "flash_wrapper", 
														:partial => "/layouts/flash", 
														:locals => { :notice => @notice }
					page.replace_html "recipe_#{@recipe.id}_title",
														:partial => "/layouts/item_basic", 
														:locals => { :item => @recipe,
								 												 :show_icon => true,
								 												 :show_title => true,
								 												 :show_link => true }
					page.replace_html "recipe_#{@recipe.id}_admin",
														:partial => "/system/item_admin_bar", 
														:locals => { :item => @recipe, 
									 											 :ref => 'show' }
  			end
  		end
  	end
  end
  
end
