class MenusController < ApplicationController

	before_filter :protect, :except => [:index, :show, :overview]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview]
	before_filter :set_system_notice, :only => [:index]

  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => params[:filter] }
      else
		    load_menus_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{MENU_CN}"
				set_page_title(info)
				set_block_title(info)

#		  	@show_todo = true
#		  	@show_favorite = true

      	format.html
      end
      # format.xml  { render :xml => @recipes_set }
    end
  end

  def show
		load_menu

		load_menus_set(@menu.user)

		@menu_index = @menus_set.index(@menu)

#		recipe = [@recipe]
#		@other_recipes_set = @recipes_set - recipe
#		recipes_conditions = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
#		related_recipes_conditions = recipes_conditions
#		@related_recipes_set = taggables_for(nil, 'Recipe', @recipe.tag_list, related_recipes_conditions, nil, nil, nil, 'RAND()') - recipe
#		same_title_recipes_conditions_list = [ "recipes.title = '#{@recipe.title}'", "recipes.common_title = '#{@recipe.title}'" ]
#		if (common_title = @recipe.common_title) && !common_title.blank?
#			same_title_recipes_conditions_list += [ "recipes.common_title = '#{common_title}'", "recipes.title = '#{common_title}'" ]
#		end
#		same_title_recipes_conditions = "#{recipes_conditions} AND (#{same_title_recipes_conditions_list.join(' OR ')})"
#		@same_title_recipes_set = recipes_for(nil, same_title_recipes_conditions, nil, 'RAND()') - recipe
#		@same_title_recipes_set_count = @same_title_recipes_set.size
#		@favorite_users_set = favorite_users(@recipe.favorites.find(:all, :limit => 12, :order => 'RAND()'))
#		@favorite_users_set_count = @favorite_users_set.size
#		@entried_matches_set = entried_matches(@recipe.entries.find(:all, :limit => 12, :order => 'RAND()'))
#
#		current = Time.now
#		if @recipe.match_id && (@match = Match.find_by_id_and_entriable_type(@recipe.match_id, 'Recipe')) && @match.doing?(current)
#			@entry = @match.find_entry(@recipe)
#		end
#
#		show_sidebar

		menu_title = item_title(@menu)
#		recipe_common_title = @recipe.common_title.strip if !@recipe.common_title.blank?
#		recipe_username = user_username(@recipe.user, true, true)
#		recipe_link_url = item_first_link(@recipe)

		info = "#{MENU_CN} - #{menu_title}"
		set_page_title(info)
		set_block_title(info)
#		@meta_description = "这是#{recipe_title}#{add_brackets(recipe_common_title, '(', ')')}的#{RECIPE_CN}信息, 来自#{recipe_username}. "
#		set_meta_keywords
#		@meta_keywords = [recipe_common_title] + @meta_keywords if !recipe_common_title.blank?
#		@meta_keywords = [ recipe_title, recipe_username, recipe_link_url ] + @meta_keywords
#		@meta_keywords << @recipe.tag_list if !@recipe.tag_list.blank?

    respond_to do |format|
      format.html do
      	log_count(@menu)
      end
      # format.xml  { render :xml => @menu }
    end
  end

  def new
    @menu = @current_user.menus.build
		@menu.is_draft = '1'

    info = "新#{MENU_CN}"
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html
      # format.xml  { render :xml => @menu }
    end
  end

  def edit
    load_menu(@current_user)

 		info = "#{EDIT_CN}#{MENU_CN} - #{item_title(@menu)}"
		set_page_title(info)
		set_block_title(info)

		respond_to do |format|
			format.html
		end
  end

  def create
  	set_tag_list

    @menu = @current_user.menus.build(params[:menu])
    item_client_ip(@menu)

    ActiveRecord::Base.transaction do
			if @menu.save
				reg_homepage(@menu)
				after_create_ok
			else
				after_create_error
			end
		end
  end

  def update
    load_menu(@current_user)
    params[:menu][:original_updated_at] = Time.now

		set_tag_list

    ActiveRecord::Base.transaction do
		  if @menu.update_attributes(params[:menu])
				reg_homepage(@menu, 'update')
				after_update_ok
		  else
				after_update_error
		  end
	  end
  end

  def destroy
    load_menu(@current_user)

		if !item_entrying?(@menu)
			ActiveRecord::Base.transaction do
				if @menu.destroy
					reg_homepage(@menu, 'destroy')
					after_destroy_ok
				end
			end
		end
  end

  def overview

  end

  def mine
  	@order = 'created_at DESC, published_at DESC'
    load_menus_set(@current_user)

  	@show_photo_todo = true
  	@show_todo = true
  	@show_manage = true

		info = "#{username_prefix(@current_user)}#{MENU_CN}"
		set_page_title(info)
		set_block_title(info)

    respond_to do |format|
      format.html { render :template => "menus/index" }
      # format.xml  { render :xml => @menus_set }
    end
  end

  private

  def set_tag_list
    if !params[:menu][:tag_list].strip.blank?
    	params[:menu][:tag_list] = clean_tags(params[:menu][:tag_list])
    end
  end

  def load_menu(user = nil)
  	if user
 			menu = user.menus.find(@self_id)
 		else
 			menu = Menu.find(@self_id)
 		end
 		if params[:action] == 'destroy' || menu.accessible?(@current_user)
 			@menu = menu
 		end
  end

  def load_menus_set(user = nil)
  	order = @order ? @order : 'published_at DESC, created_at DESC'
    menu_conditions = common_filter_conditions(params[:filter], 'Menu', user)
    @menus_set = menus_for(user, menu_conditions.join(' AND '), nil, order)
#    @menus_set = []
  	@menus_set_count = @menus_set.size
  end

  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}, 快去#{ADD_CN}几#{unit_for('Photo')}#{PHOTO_CN}和几#{unit_for('Course')}#{COURSE_CN}吧!"
				redirect_to @menu
			end
			# format.xml  { render :xml => @menu, :status => :created, :location => @menu }
		end
  end

  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"

				info = "新#{MENU_CN}"
				set_page_title(info)
				set_block_title(info)

				render :action => "new"
				clear_notice
			end
			# format.xml  { render :xml => @menu.errors, :status => :unprocessable_entity }
		end
  end

  def after_update_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"
				redirect_to @menu
			end
			# format.xml  { head :ok }
		end
  end

  def after_update_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"

				info = "#{EDIT_CN}#{MENU_CN} - #{item_title(@menu)}"
				set_page_title(info)
				set_block_title(info)

				render :action => "edit"
				clear_notice
			end
			# format.xml  { render :xml => @menu.errors, :status => :unprocessable_entity }
		end
  end

  def after_destroy_ok
		respond_to do |format|
		  format.html do
		  	flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"
		  	redirect_to url_for(:controller => 'menus', :action => 'mine', :filter => params[:filter], :page => params[:page])
		  end
		  # format.xml  { head :ok }
		end
  end
  
end
