class RecipesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show, :overview, :tags]

  # GET /recipes
  # GET /recipes.xml
  def index
    if !(@user && @user == @current_user)
    	@integrality = 'more_required'
    end
      
    load_recipes_set(@user)
   	items_paginate(@recipes_set)
   	@recipes = @items
    
  	if @user
  		info = "#{@user_title}的#{@self_name} (#{@recipes_set_count})"
  		@recipes_html_id_suffix = "user_#{@user_id}"
  	else
			info = "#{@self_name} (#{@recipes_set_count})"
			@recipes_html_id_suffix = "all_users"
  	end
  	
  	@recipes_html_id = "recipes_of_#{@recipes_html_id_suffix}"
  	
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
      if @user && @user == @current_user
      	@show_header_link = true
      	@show_photo_todo = true
      	@show_todo = true
      	format.html { redirect_to :controller => 'mine', :action => 'recipes' }
      else
      	format.html # index.html.erb
      end
      format.xml  { render :xml => @recipes }
    end    

  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show 
		session[:return_to] = nil
		
		load_recipe(nil)
		
    if @recipe.user != @current_user
    	@integrality = 'more_required'
    end
			
		load_recipes_set(@recipe.user)
		
		@cover_photo = cover_photo(@recipe)
    @photos_set = photos_for(nil, @self_type, @self_id, 'created_at')
    @photos_set_count = @photos_set.size
    @photos = []
    if @cover_photo
	    @photos << @cover_photo
	    @photos += (@photos_set - @photos)[0..4]
		end
		
		@review_name = name_for('review')
		@review_unit = unit_for('review')
    @reviews_set = reviews_for(nil, @self_type, @self_id, nil, nil, 'created_at DESC')
    @reviews_set_count = @reviews_set.size
    @reviews = @reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]													
		
		info = "#{@self_name} - #{@recipe.title}"
		
		set_page_title(info)
		set_block_title(info)
		
		store_location
		
		current_view_count = @recipe.view_count ? @recipe.view_count : 0
		@recipe.update_attribute('view_count', current_view_count + 1)
																							 
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/new
  # GET /recipes/new.xml
  def new
    @recipe = @current_user.recipes.build

		load_recipes_set(@current_user)
    
    info = "新#{@self_name}"
    
		set_page_title(info)
		set_block_title(info)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipe }
    end
    
  end

  # GET /recipes/1/edit
  def edit
    load_recipe(@current_user)
    
    load_recipes_set(@current_user)
    
 		info = "#{EDIT_CN}#{@self_name} - #{@recipe.title}"
		
		set_page_title(info)
		set_block_title(info)
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    @recipe = @current_user.recipes.build(params[:recipe])
    @recipe.privacy = '10'
    
		if @recipe.save
			@recipe.tag_list = params[:tags]
			after_create_ok
		else
			after_create_error
		end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    load_recipe(@current_user)
    @recipe.privacy = '10'

	  if @recipe.update_attributes(params[:recipe])
	  	@recipe.tag_list = params[:tags]
			after_update_ok
	  else
			after_update_error
	  end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    load_recipe(@current_user)

		@recipe.destroy

		after_destroy_ok
  end
  
  # /recipes/overview
  def overview
  	@integrality = 'more_required'
  	
  	@highlighted_recipes = highlighted_recipes(nil, @integrality, Time.today - 60.days, nil, 'created_at DESC')
  	@highlighted_recipe = @highlighted_recipes.rand
	  
	  load_recipes_set(nil)
	  @recipes = @recipes_set[0..MATRIX_ITEMS_COUNT_PER_PAGE_S - 1]
	  
	  load_recipe_reviews_set(nil)
	  @recipe_reviews = @recipe_reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
	  
	  @tags_set = recipe_tags_cloud(nil, nil, 'name', 0)
	  @tags = recipe_tags_cloud(nil, 100, 'count desc', 3)
	  
	  info = "#{@self_name}"
		set_page_title(info)
		
		show_sidebar
  end
  
  def tags
  	@tags = recipe_tags_cloud(nil, nil, 'name', 0)
  
  	if params[:id]
	  	load_tagged_recipes(nil, params[:id])
		 	
	   	items_paginate(@recipes_set)
	   	@recipes = @items
		 	
		 	info = "#{@self_name}#{TAG_CN} - #{params[:id]} (#{@recipes_set_count})"
		 	
			set_page_title(info)
			set_block_title(info)
	 		@show_header_link = false
	 		
	 		show_sidebar
	 		
	    respond_to do |format|
	     	flash[:notice] = "共有#{@recipes_set_count}#{UNIT_RECIPE_CN}#{RECIPE_CN}包含这个#{TAG_CN}......"
	     	format.html { render :action => 'index' }
	      format.xml  { render :xml => @recipes }
	    end
	    clear_notice
		else
	  	info = "#{@self_name}#{TAG_CN} (#{@tags.size})"
			@show_header_link = false
	  	
	  	set_page_title(info)
			set_block_title(info)
			
	    respond_to do |format|
	     	format.html { render :template => "tags/index" }
	      format.xml  { render :xml => @tags }
	    end
		end
  end
  
  def search
  	id = params[:id]
  	keywords = keywords(id)
  	if keywords != []
  		load_search_result(nil, keywords)
  		@conditions = conditions(id)
  	else
  		@recipes_set = []
  		@recipes_set_count = 0
  		@conditions = ''
  	end
  	
   	items_paginate(@recipes_set)
   	@recipes = @items
  	
	 	info = "#{@self_name}#{SEARCH_CN} - #{@conditions} (#{@recipes_set_count})"
	 	
		set_page_title(info)
		set_block_title(info)
 		@show_header_link = false
 		
    respond_to do |format|
    	if @conditions != ''
    		if @recipes_set_count > 0
		    	flash[:notice] = "共有#{@recipes_set_count}#{UNIT_RECIPE_CN}#{RECIPE_CN}符合#{SEARCH_CN}条件......"
		    else
		    	flash[:notice] = "#{SORRY_CN}, 没有符合#{SEARCH_CN}条件的#{RECIPE_CN}!"
		    end
	    else
	    	flash[:notice] = "#{SORRY_CN}, 你还没有#{INPUT_CN}#{SEARCH_CN}条件!"
	    end
     	format.html { render :action => 'index' }
      format.xml  { render :xml => @recipes }
    end
    clear_notice
  end
  
  private
  
  def load_recipe(user)
  	if user
 			@recipe = user.recipes.find(@self_id)
 		else
 			@recipe = Recipe.find(@self_id)
 		end
  end
  
  def load_recipes_set(user)
 		@recipes_set = recipes_for(user, @integrality, nil, nil, 'created_at DESC')
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_recipe_reviews_set(user)
  	@recipe_reviews_set = reviews_for(user, @self_type, nil, nil, nil, 'created_at DESC')
  	@recipe_reviews_set_count = @recipe_reviews_set.size
  end

	def load_tagged_recipes(user, tag)
		@recipes_set = tagged_items(user, 'recipe', tag, 'created_at DESC', recipes_conditions('more_required', nil, nil))
		@recipes_set_count = @recipes_set.size
	end
	
	def load_search_result(user, keywords)
		@recipes_set = search_result_recipes(user, keywords, 'created_at DESC', recipes_conditions('more_required', nil, nil))
		@recipes_set_count = @recipes_set.size
	end
  
  def after_create_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}!"
			format.html { redirect_to @recipe }
			format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
		end
  end
  
  def after_create_error
  	respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
			
			load_recipes_set(@current_user)
			 		
			info = "新#{@self_name}"
			 		
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
  
  def after_update_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_to @recipe }
			format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
			
			load_recipes_set(@current_user)
			
			info = "#{EDIT_CN}#{@self_name} - #{@recipe.title}"
			
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
  
  def after_destroy_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
		  format.html { redirect_to session[:return_to] }
		  format.xml  { head :ok }
		end
  end
  
end
