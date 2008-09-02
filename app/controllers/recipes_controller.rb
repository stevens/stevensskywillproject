class RecipesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show, :overview, :reviews, :tags]

  # GET /recipes
  # GET /recipes.xml
  def index
  	if params[:id] == 'latest'
  		@recipes_set = recipes_for(nil, true, false, Time.today - 100.days, nil, 'created_at DESC')
  		@recipes_set_count = @recipes_set.size
  		info = "最新的#{@self_name}(#{@recipes_set_count})"
  	else
	  	if @user
	  		if @user == @current_user
	  			load_recipes_mine
	  			info = "我的#{@self_name}(#{@recipes_set_count})"
	  		else
	  			load_recipes_user(@user)
	  			info = "#{@user_title}的#{@self_name}(#{@recipes_set_count})"
	  		end
	  	else
	  		load_recipes_all
	  		info = "#{@self_name}(#{@recipes_set_count})"
	  	end
  	end
  
	 	recipes_paginate
 		
		set_page_title(info)
		set_block_title(info)
		@show_header_link = false
 		
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine' }
      else
      	format.html # index.html.erb
      end
      format.xml  { render :xml => @recipes }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show 
		load_recipe(nil)
		
		@cover_photo = cover_photo(@recipe)
    @photos_set = photos_for(nil, @self_type, @self_id, 'created_at')
    @photos_set_count = @photos_set.size
    @photos = []
    if @cover_photo
	    @photos << @cover_photo
	    @photos += (@photos_set - @photos)[0..3]
		end
		
		@review_name = name_for('review')
		@review_unit = unit_for('review')
    @reviews_set = reviews_for(nil, @self_type, @self_id, nil, nil, 'created_at DESC')
    @reviews_set_count = @reviews_set.size
    @reviews = @reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
			
		if @recipe_user == @current_user
			load_recipes_mine
			info = "我的#{@self_name}: #{@recipe_title}"
		else
			load_recipes_user(@recipe_user)
			info = "#{@recipe_user_title}的#{@self_name}: #{@recipe_title}"
		end														
		
		set_page_title(info)
		set_block_title(info)
																							 
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/new
  # GET /recipes/new.xml
  def new
    @recipe = @current_user.recipes.build

		load_recipes_mine
    
    info = "#{CREATE_CN}新#{@self_name}"
    
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
    
    load_recipes_mine
    
 		info = "#{EDIT_CN}#{@self_name}: #{@recipe_title}"
		
		set_page_title(info)
		set_block_title(info)
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    @recipe = @current_user.recipes.build(params[:recipe])
    
    @recipe.tag_list = params[:tags]
    
		if @recipe.save
			after_create_ok
		else
			after_create_error
		end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    load_recipe(@current_user)
    
    @recipe.tag_list = params[:tags]

	  if @recipe.update_attributes(params[:recipe])
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
  
  # /mine/recipes
  def mine
	 	load_recipes_mine
	 	
		recipes_paginate
	 	
	 	info = "我的#{@self_name}(#{@recipes_set_count})"
	 	
		set_page_title(info)
		set_block_title(info)
 		@show_header_link = true
 		
    respond_to do |format|
     	format.html { render :action => 'index' }
      format.xml  { render :xml => @recipes }
    end
  end
  
  # /recipes/overview
  def overview
  	@highlighted_recipes_set = highlighted_recipes(nil, true, false, Time.today - 30.days, nil, nil)
  	@highlighted_recipe = @highlighted_recipes_set.rand
  	
  	@latest_recipes_set = recipes_for(nil, true, false, Time.today - 30.days, nil, 'created_at DESC')
  	@latest_recipes = @latest_recipes_set[0..MATRIX_ITEMS_COUNT_PER_PAGE_S - 1]
  	@latest_reviews_set = reviews_for(nil, 'recipe', nil, Time.today - 100.days, nil, 'created_at DESC')
  	@latest_reviews = @latest_reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
	  
	  @tags = recipe_tags_cloud(nil)
	  
	  info = "#{@self_name}"
		set_page_title(info)
		
		show_sidebar
  end
  
  def reviews
		if params[:id] == 'latest'
  		@reviews_set = reviews_for(nil, 'recipe', nil, Time.today - 100.days, nil, 'created_at DESC')			
			@reviews_set_count = @reviews_set.size
		
			info = "最新的#{@self_name}#{REVIEW_CN}(#{@reviews_set_count})"
		else
			@reviews_set = reviews_for(nil, 'recipe', nil, nil, nil, 'created_at DESC')
			@reviews_set_count = @reviews_set.size
	  	
	  	info = "#{@self_name}#{REVIEW_CN}(#{@reviews_set_count})"
	 	end
	 		
	 	@reviews = @reviews_set.paginate :page => params[:page], 
 															 			 :per_page => LIST_ITEMS_COUNT_PER_PAGE_S
 															 			   	
  	
		@show_header_link = false
  	@show_review_parent = true
  	
  	set_page_title(info)
		set_block_title(info)

    respond_to do |format|
     	format.html { render :template => "reviews/index" }
      format.xml  { render :xml => @reviews }
    end 	
  end
  
  def tags
  	if params[:id]
	  	load_tagged_recipes(nil, params[:id])
		 	
			recipes_paginate
		 	
		 	info = "#{@self_name}#{TAG_CN}: #{params[:id]}(#{@recipes_set_count})"
		 	
			set_page_title(info)
			set_block_title(info)
	 		@show_header_link = false
	 		
	    respond_to do |format|
	     	flash[:notice] = "共有#{@recipes_set_count}#{UNIT_RECIPE_CN}#{RECIPE_CN}包含这个#{TAG_CN}......"
	     	format.html { render :action => 'index' }
	      format.xml  { render :xml => @recipes }
	    end
	    clear_notice
		else
			@tags = recipe_tags_cloud(nil)
			
	  	info = "#{@self_name}#{TAG_CN}(#{@tags.size})"
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
  	
  	recipes_paginate
  	
	 	info = "#{@self_name}#{SEARCH_CN}: #{@conditions}(#{@recipes_set_count})"
	 	
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
  	if @recipe
  		@recipe_title = @recipe.title
  		@recipe_user = @recipe.user
  		@recipe_user_title = @recipe_user.login if @recipe_user
  	end
  end
  
  def load_recipes_all
  	@recipes_set = Recipe.find(:all, :order => 'created_at DESC')
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_recipes_user(user)
  	@recipes_set = user.recipes.find(:all, :order => 'created_at DESC')
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_recipes_mine
		load_recipes_user(@current_user)
  end

	def load_tagged_recipes(user, tag)
		@recipes_set = tagged_items(user, 'recipe', tag, 'created_at DESC')
		@recipes_set_count = @recipes_set.size
	end
	
	def load_search_result(user, keywords)
		@recipes_set = search_result_recipes(user, keywords, 'created_at DESC')
		@recipes_set_count = @recipes_set.size
	end
	
  def recipes_paginate
	 	@recipes = @recipes_set.paginate :page => params[:page], 
 															 			 :per_page => LIST_ITEMS_COUNT_PER_PAGE_S
  end
  
  def after_create_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}!"
			format.html { redirect_to recipe_url(@recipe) }
			format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
		end
  end
  
  def after_create_error
  	respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
			
			load_recipes_mine
			 		
			info = "#{CREATE_CN}新#{@self_name}"
			 		
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
  
  def after_update_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
			format.html { redirect_to recipe_url(@recipe) }
			format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
			
			load_recipes_mine
			
			info = "#{EDIT_CN}我的#{@self_name}: #{@recipe_title}"
			
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
  
  def after_destroy_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
		  format.html { redirect_to :action => "mine" }
		  format.xml  { head :ok }
		end
  end
  
end
