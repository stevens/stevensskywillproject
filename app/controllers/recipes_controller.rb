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

		recipe = [@recipe]
		@other_recipes_set = @recipes_set - recipe
		related_recipes_conditions = recipe_conditions({:photo_required => recipe_photo_required_cond, :status => recipe_status_cond, :privacy => recipe_privacy_cond, :is_draft => recipe_is_draft_cond})
		@related_recipes_set = taggables_for(nil, 'Recipe', @recipe.tag_list, conditions = related_recipes_conditions) - recipe

    log_count(@recipe)												
		
		@show_sidebar = true
		
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
  
  def publish
  	load_recipe(@current_user)
    if params[:to_publish]
	    @recipe.is_draft = '0'
	    @recipe.published_at = @recipe.get_published_at
			@notice = "你已经发布了这#{@self_unit}#{@self_name}!"
	  else
	  	@recipe.is_draft = '1'
			@notice = "你已经将这#{@self_unit}#{@self_name}设置为草稿!"
	  end
  	
		Recipe.update(@recipe.id, {:is_draft => @recipe.is_draft, :published_at => @recipe.published_at})

		after_publish_ok
  end
  
  # /recipes/overview
  def overview
	  load_recipes_set
	  load_reviews_set
	  load_tags_set
	  
  	@highlighted_recipe = highest_rated_items(@recipes_set)[0..99].rand
  	
  	@highest_rated_recipes = highest_rated_items(@recipes_set)[0..9]
	  
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
 		if recipe_accessible?(recipe)
 			@recipe = recipe
 		end
  end
  
  def load_recipes_set(user = nil)
 		@recipes_set = recipes_for(user)
  	@recipes_set_count = @recipes_set.size
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
			format.js do
				render :update do |page|
					page.replace_html "flash_wrapper", 
														:partial => "/layouts/flash", 
														:locals => {:notice => @notice}
					page.replace_html "recipe_#{@recipe.id}_title",
														:partial => "/recipes/recipe_title", 
														:locals => {:item => @recipe}
					page.replace_html "recipe_#{@recipe.id}_todo",
														:partial => "/recipes/recipe_todo", 
														:locals => {:item => @recipe}
				end
			end
  	end
  end
  
end
