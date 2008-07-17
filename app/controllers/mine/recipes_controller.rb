class Mine::RecipesController < ApplicationController
	
	before_filter :protect
  before_filter :load_user
  before_filter :set_photo_type
	  
  # GET /recipes
  # GET /recipes.xml
  def index
 		@recipes = @user.recipes.paginate :page => params[:page], 
 																			:per_page => ITEMS_COUNT_PER_PAGE, 
 																			:order => 'updated_at DESC'
 		
 		info = sysinfo('300006', '', {:title => I_CN}, '', {:type => RECIPE_CN, :count => @recipes.total_entries})
		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recipes }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show 
    @recipe = @user.recipes.find(params[:id])
    @recipe_submitter = @user
    @photo = cover_photo(@recipe)
    @photo_style = 'detail'
    @photo_path = mine_recipe_photo_path(@recipe, @photo)
    @new_photo_path = new_mine_recipe_photo_path(@recipe)
    @photos_all = photos_all(@photo_type, @recipe, @user)
		@photos_paginate = @photos_all.paginate :page => params[:page],
																						:per_page => PHOTOS_COUNT_PER_NAV,
																						:order => 'created_at'
		
 		info = sysinfo('300006', SEE_CN, {:title => I_CN}, '', {:type => RECIPE_CN, :title => @recipe.title})
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
    @recipe = @user.recipes.build
    @prep_time_hour = 0
    @prep_time_minute = 0
    @cook_time_hour = 0
    @cook_time_minute = 0
    
 		info = sysinfo('300002', CREATE_CN, {:title => I_CN}, NEW_CN, {:type => RECIPE_CN})
		set_page_title(info)
		set_block_title(info)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe = @user.recipes.find(params[:id])
    @prep_time_hour = @recipe.prep_time_display[:h]
    @prep_time_minute = @recipe.prep_time_display[:m]
    @cook_time_hour = @recipe.cook_time_display[:h]
    @cook_time_minute = @recipe.cook_time_display[:m]
    
 		info = sysinfo('300006', EDIT_CN, {:title => I_CN}, '', {:type => RECIPE_CN, :title => @recipe.title})
		set_page_title(info)
		set_block_title(info)
		
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    @recipe = @user.recipes.build(params[:recipe])
    @recipe.tag_list = params[:tags]
    @recipe.prep_time = params[:prep_time_hour].to_i.hours + params[:prep_time_minute].to_i.minutes
    @recipe.cook_time = params[:cook_time_hour].to_i.hours + params[:cook_time_minute].to_i.minutes
    
    respond_to do |format|
      if @recipe.save
				flash[:notice] = sysinfo('100001', CREATE_CN, nil , NEW_CN, {:type => RECIPE_CN, :count => 1, :unit => UNIT_1_CN})
				format.html { redirect_to(new_mine_recipe_photo_path(@recipe)) }
        format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
      else
        flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => RECIPE_CN})
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
        
		 		info = sysinfo('300002', CREATE_CN, {:title => I_CN}, NEW_CN, {:type => RECIPE_CN})
				set_page_title(info)
				set_block_title(info)
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    @recipe = @user.recipes.find(params[:id])
    @recipe.tag_list = params[:tags]
    @recipe.prep_time = params[:prep_time_hour].to_i.hours + params[:prep_time_minute].to_i.minutes
    @recipe.cook_time = params[:cook_time_hour].to_i.hours + params[:cook_time_minute].to_i.minutes

    respond_to do |format|
      if @recipe.update_attributes(params[:recipe])
				flash[:notice] = sysinfo('100001', UPDATE_CN, nil , '', {:type => RECIPE_CN, :count => 1, :unit => UNIT_1_CN})
        format.html { redirect_to([:mine, @recipe]) }
        format.xml  { head :ok }
      else
				flash[:notice] = sysinfo('100002', INPUT_CN, nil, '', {:type => RECIPE_CN})
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }

     		info = sysinfo('300006', EDIT_CN, {:title => I_CN}, '', {:type => RECIPE_CN, :title => @recipe.title})
				set_page_title(info)
				set_block_title(info)
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    @recipe = @user.recipes.find(params[:id])
    @recipe.destroy

    respond_to do |format|
			flash[:notice] = sysinfo('100001', DELETE_CN, nil , '', {:type => RECIPE_CN, :count => 1, :unit => UNIT_1_CN})
      format.html { redirect_to(mine_recipes_path) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def set_photo_type
  	@photo_type = RECIPE_EN
  end
  
end
