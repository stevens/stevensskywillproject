class RecipesController < ApplicationController
	
	before_filter :protect, :except => [:index, :show, :overview]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview]
	before_filter :system_notice, :only => [:overview, :mine, :new, :edit]
	
  # GET /recipes
  # GET /recipes.xml
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine' }
      else
		    load_recipes_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{RECIPE_CN} (#{@recipes_set_count})"
				set_page_title(info)
				set_block_title(info)
				
      	format.html # index.html.erb
      end
      format.xml  { render :xml => @recipes_set }
    end   

  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
		load_recipe
			
		load_recipes_set(@recipe.user)
		
		@photos_set = []
		if @cover_photo = cover_photo(@recipe)
			@photos_set << @cover_photo
			@photos_set = @recipe.photos - @photos_set
		end
    
    log_count(@recipe)												
		
		info = "#{RECIPE_CN} - #{@recipe.title}"
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

		load_recipes_set(@current_user)
    
    info = "新#{RECIPE_CN}"
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
    
	  if @recipe.update_attributes(params[:recipe])
	  	@recipe.tag_list = params[:tags].strip if params[:tags] && params[:tags].strip != @recipe.tag_list
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
	  load_recipes_set
	  load_reviews_set
	  load_tags_set
	  
  	@highlighted_recipe = highlighted_items(@recipes_set[0..99]).rand
	  
	  info = RECIPE_CN
		set_page_title(info)
		
		show_sidebar
  end
  
  def mine
    load_recipes_set(@current_user)
    
  	@show_photo_todo = true
  	@show_todo = true
		
		info = "#{username_prefix(@current_user)}#{RECIPE_CN} (#{@recipes_set_count})"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "recipes/index" }
      format.xml  { render :xml => @recipes_set }
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
  	
   	@recipes = items_paginate(@recipes_set)
  	
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
  
  def system_notice
  	# info = "号外: 可爱的蜂厨们, 现在可以对食谱进行隐私设置了!"
  	# set_system_notice(info)
  end
  
  def load_recipe(user = nil)
  	if user
 			recipe = user.recipes.find(@self_id)
 		else
 			recipe = Recipe.find(@self_id)
 		end
 		if @current_user
 			if recipe.user == @current_user
 				@recipe = recipe
 			else
 				if recipe.cover_photo_id && recipe.status.to_i >= 1 && recipe.privacy != '90'
 					@recipe = recipe
 				else
 					@recipe = nil
 				end
 			end
 		else
 			if recipe.cover_photo_id && recipe.status.to_i >= 1 && recipe.privacy == '10'
 				@recipe = recipe
 			else
 				@recipe = nil
 			end
 		end
  end
  
  def load_recipes_set(user = nil)
 		@recipes_set = recipes_for(user)
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_reviews_set(user = nil)
  	@reviews_set = reviews_for(user, review_conditions({:reviewable_type => 'Recipe', :reviewable_id => @self_id}), 'Recipe', recipe_conditions({:photo_required => recipe_photo_required_cond(user), :status => recipe_status_cond(user), :privacy => recipe_privacy_cond(user), :is_draft => recipe_is_draft_cond(user)}))
  	@reviews_set_count = @reviews_set.size
  end
  
  def load_tags_set(user =nil)
	  @tags_set = tags_for(user, 'Recipe')
  	@tags_set_count = @tags_set.size
  	@custom_tags_set = tags_for(user, 'Recipe', nil, TAG_COUNT_AT_LEAST, TAG_COUNT_AT_MOST, nil, order = 'count DESC')
  end
	
	def load_search_result(user, keywords)
		@recipes_set = search_result_recipes(user, keywords, 'created_at DESC', recipe_conditions({:photo_required => true, :status => '1', :privacy => '11', :is_draft => '0'}))
		@recipes_set_count = @recipes_set.size
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
  
end
