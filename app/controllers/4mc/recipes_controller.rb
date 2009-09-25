class RecipesController < ApplicationController
  before_filter :preload_models
  before_filter :protect, :except => [:index, :show, :overview, :pk_game]
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

  ## MemCached 预加载Recipe和Review模型
  def preload_models()
    Review
    Recipe
  end
  ## end

  # GET /recipes
  # GET /recipes.xml
  def index
#    CACHE.flush()
    respond_to do |format|
#      if @user && @user == @current_user
#      	format.html { redirect_to :action => 'mine', :filter => params[:filter] }
#      else
		    load_recipes_set(@user)
        if !params[:filter].blank?
          codeable_type = @current_user && @user == @current_user ? 'recipe_filter_my' : 'recipe_filter_ta'
          filter_title = filter_title(codeable_type, params[:filter])
          filter_suffix = filter_suffix(filter_title)
        end
		  	info = "#{username_prefix(@user)}#{RECIPE_CN}列表#{filter_suffix}"
				set_page_title(info)
				set_block_title(info)
				
		  	@show_todo = true
		  	@show_favorite = true

        @meta_description = "这是#{username_prefix(@user)}#{filter_title}#{RECIPE_CN}列表，可以浏览各种#{filter_title}#{RECIPE_CN}（菜谱）的图片和文字摘要信息。"

      	format.html
#      end
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

    same_title_recipes_conditions_list = [ "recipes.title = '#{@recipe.title}'", "recipes.common_title = '#{@recipe.title}'" ]
		if (common_title = @recipe.common_title) && !common_title.blank?
			same_title_recipes_conditions_list += [ "recipes.common_title = '#{common_title}'", "recipes.title = '#{common_title}'" ]
		end
		same_title_recipes_conditions = "#{recipes_conditions} AND (#{same_title_recipes_conditions_list.join(' OR ')})"
		@same_title_recipes_set = recipes_for(nil, same_title_recipes_conditions, nil, 'RAND()') - recipe
		@same_title_recipes_set_count = @same_title_recipes_set.size

    related_recipes_conditions = recipes_conditions
		@related_recipes_set = taggables_for(nil, 'Recipe', @recipe.tag_list, related_recipes_conditions, nil, nil, nil, 'RAND()') - recipe - @same_title_recipes_set
		
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
		@meta_description = "这是#{recipe_title}#{add_brackets(recipe_common_title, '（', '）')}的#{RECIPE_CN}详细信息，来自#{recipe_username}，其中包括食谱（菜谱）的名称、难度、成本、时间、出品量、描述、用料、工具、做法、贴士，以及食谱标签、食谱图片、食谱评论、食谱评分和相关食谱等内容。"
		@meta_keywords = []
    @meta_keywords << @recipe.tag_list if !@recipe.tag_list.blank?
    @meta_keywords += [ recipe_title, recipe_username, recipe_link_url ]
    @meta_keywords << recipe_common_title if !recipe_common_title.blank?
    @meta_keywords += default_meta_keywords('Recipe')
#		@meta_keywords = [recipe_common_title] + @meta_keywords if !recipe_common_title.blank?

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

    @meta_description = "这是创建#{RECIPE_CN}的界面，通过这个界面可以在#{SITE_NAME_CN}创建和上传一个新#{RECIPE_CN}（菜谱）。"

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

    @meta_description = "这是编辑#{RECIPE_CN}的界面，通过这个界面可以在#{SITE_NAME_CN}编辑和修改一个#{RECIPE_CN}（菜谱）。"
		
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
#    new_recipe = @current_user.recipes.build(params[:recipe])
    if params[:recipe][:privacy].nil?
      params[:recipe][:privacy] = @recipe.privacy
    end
    # for love recipes
    current_roles = @recipe.roles || ''
    if (params[:recipe][:privacy] == '10' && params[:recipe][:from_type] == '1' && @recipe.is_draft == '0' && time_iso_format(@recipe.published_at) >= '2009-08-01 00:00:00')
      unless(current_roles.include?('21'))
        params[:recipe][:roles] = '21 ' + current_roles
        begin
          CACHE.delete('overview_love_recipes_set')
          CACHE.delete('overview_love_users_set')
        rescue Memcached::NotFound
        end
      end
    else
      if(current_roles.include?('21'))
        params[:recipe][:roles] = current_roles.gsub('21', '')
        begin
          CACHE.delete('overview_love_recipes_set')
          CACHE.delete('overview_love_users_set')
        rescue Memcached::NotFound
        end
      end
    end
    # end
    
    new_recipe = @recipe.user.recipes.build(params[:recipe])
    # new_recipe.cover_photo_id = @recipe.cover_photo_id
    # new_recipe.published_at = @recipe.published_at
    # new_recipe.status = new_recipe.get_status
    # new_recipe.is_draft = new_recipe.get_is_draft
    # new_recipe.published_at = new_recipe.get_published_at
    
    # params[:recipe][:status] = new_recipe.status
    # params[:recipe][:is_draft] = new_recipe.is_draft
    # params[:recipe][:published_at] = new_recipe.published_at
    params[:recipe][:original_updated_at] = Time.now if @recipe.user == @current_user
    params[:recipe][:status] = new_recipe.get_status
		
		set_tag_list
    
    ActiveRecord::Base.transaction do
		  if @recipe.update_attributes(params[:recipe])
		  	# @recipe.tag_list = params[:tags].strip if params[:tags] && params[:tags].strip != @recipe.tag_list
				reg_homepage(@recipe, 'update')
        begin
          CACHE.delete('overview_recipes_set')
          CACHE.delete('overview_all_recipes_set')
          CACHE.delete('overview_tags_set')
        rescue Memcached::NotFound
        end
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
          begin
            CACHE.delete('overview_recipes_set')
            CACHE.delete('overview_all_recipes_set')
            CACHE.delete('overview_love_recipes_set')
            CACHE.delete('overview_love_users_set')
            CACHE.delete('overview_tags_set')
            CACHE.delete('overview_reviews_set')
          rescue Memcached::NotFound
          end
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
      # the following code is for love recipe
      if(@recipe.from_type == '1' && @recipe.privacy == '10')
        new_attrs = { :roles => ' 21', :is_draft => '0', :published_at => current, :original_updated_at => current }
        @notice = "你已经发布了1#{@self_unit}爱心#{@self_name}!"
        begin
          CACHE.delete('overview_love_recipes_set')
          CACHE.delete('overview_love_users_set')
        rescue Memcached::NotFound
        end
      else
        new_attrs = { :is_draft => '0', :published_at => current, :original_updated_at => current }
        @notice = "你已经发布了1#{@self_unit}#{@self_name}!"
      end
      # end

			#new_attrs = { :is_draft => '0', :published_at => current, :original_updated_at => current }
			#@notice = "你已经发布了1#{@self_unit}#{@self_name}!"
			
			if @recipe.update_attributes(new_attrs)
				reg_homepage(@recipe, 'update')
        begin
          CACHE.delete('overview_recipes_set')
          CACHE.delete('overview_all_recipes_set')
          CACHE.delete('overview_tags_set')
        rescue Memcached::NotFound
        end
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

    recipe_title = item_title(@recipe)
		recipe_common_title = @recipe.common_title.strip if !@recipe.common_title.blank?
		recipe_username = user_username(@recipe.user, true, true)

 		info = "分享#{RECIPE_CN} - #{recipe_title}"
		set_page_title(info)
		set_block_title(info)

    @meta_description = "这是#{recipe_title}#{add_brackets(recipe_common_title, '（', '）')}的#{RECIPE_CN}分享信息，来自#{recipe_username}，其中包括食谱（菜谱）的图文链接代码和效果预览等内容。"
	end
  
  def overview
    @recipes_limit = 18
    @action_flag = 1
	  load_recipes_set
    # 加载爱心食谱
    load_love_recipes
    load_love_users
    # end
#	  load_random_recipes
	  load_choice_recipes
	  load_reviews_set
	  load_tags_set

    @meta_description = "这是#{SITE_NAME_CN}的#{RECIPE_CN}综览，是#{RECIPE_CN}（菜谱）频道的首页，其中包括热门食谱（红食谱）、精选食谱、新鲜食谱，以及食谱搜索、食谱浏览、食谱排行、食谱评论、食谱标签、爱心食谱行动等内容。"

    @highlighted_recipe = @choice_recipes.rand

#  	ranked_recipes_set = highest_rated_items(@recipes_set)[0..99]
#  	if ranked_recipes_set
#	  	@highlighted_recipe = ranked_recipes_set.rand
#	  	if @highlighted_recipe_rank = ranked_recipes_set.index(@highlighted_recipe)
#	  		@highlighted_recipe_rank += 1
#	  	end
#	  	@highest_rated_recipes = ranked_recipes_set[0..19]
#	  end
  	# @random_recipes = random_items(@recipes_set, 12)
	  
	  info = RECIPE_CN
		set_page_title(info)
		
		show_sidebar
  end
  
  def mine
#  	@order = 'created_at DESC, published_at DESC'
#    load_recipes_set(@current_user)
#
#  	@show_photo_todo = true
#  	@show_todo = true
#  	@show_manage = true
#
#		info = "#{username_prefix(@current_user)}#{RECIPE_CN}"
#		set_page_title(info)
#		set_block_title(info)
		
    respond_to do |format|
#      format.html { render :template => "recipes/index" }
      format.html { redirect_to :user_id => @current_user.id, :action => 'index', :filter => params[:filter] }
      # format.xml  { render :xml => @recipes_set }
    end
  end

  # 爱心食谱行动数据统计
  def love_recipe_stats
    if access_control(@current_user)
      season_numbers = %w[一 二 三 四 五 六 七 八 九 十]
      season_number = season_numbers[params[:season].to_i - 1]
      info = "爱心食谱行动（第#{season_number}季）数据统计"
      set_page_title(info)
      set_block_title(info)

      @meta_description = "这是蜂厨慈善创意活动——爱心食谱行动（第#{season_number}季）的数据统计信息，包括月度统计数据和累积统计数据等内容。"

      case params[:season]
      when '1'
        @season_start = Time.local(2009, 8, 1).beginning_of_day
        @season_end = (@season_start + 1.year - 1.day).end_of_day
      end

      if !params[:stat_at].blank?
        stat_at = params[:stat_at].to_time.end_of_day
      else
        stat_at = @season_end
      end

      stat_from = @season_start
      if stat_at > @season_start && stat_at < @season_end
        stat_to = stat_at
      else
        stat_to = @season_end
      end

      user = User.find_by_id(params[:user_id].to_i) if !params[:user_id].blank?

      @user_stats_group = []

      recipes_set = love_recipes(user, '21', stat_from.strftime("%Y-%m-%d %H:%M:%S"), stat_to.strftime("%Y-%m-%d %H:%M:%S"))

      if recipes_set != []
        @user_recipes_groups = recipes_set.group_by { |recipe| (recipe[:user_id]) } #.sort { |a, b| a <=> b }

        @total_stats = [nil]
        user_index = 0
        most_temp = [nil]
        most_choiced_temp = [nil]

        @user_recipes_groups.each do |user_id, user_recipes|
          user_stats = [user_id]
          phase_start = stat_from.beginning_of_month
          user_recipes_count_sum = 0
          user_choiced_recipes_count_sum = 0
          user_more_recipes_months_count = 0

          1.upto(12) do |m|
            phase_end = phase_start.end_of_month
            user_recipes_count = 0
            user_choiced_recipes_count = 0
            users_count = 0
            more_recipes_users_count = 0
            more_recipes_users_count_total = 0

            for user_recipe in user_recipes
              user_recipe_published_at = user_recipe.published_at.to_time
              if user_recipe_published_at >= phase_start && user_recipe_published_at <= phase_end
                user_recipes_count += 1
                user_recipes_count_sum += 1
                if user_recipe.roles.include?('11')
                  user_choiced_recipes_count += 1
                  user_choiced_recipes_count_sum += 1
                end
              end
            end

            users_count = 1 if user_recipes_count > 0

            if user_recipes_count >= 5
              user_more_recipes_months_count += 1
              more_recipes_users_count = 1
            end

            phase_month = phase_start.strftime("%Y-%m")
            is_most = false
            is_most_choiced = false

            if user_index == 0
              is_most = true if user_recipes_count > 0
              most_temp << [ phase_month, 0 ]
              most_choiced_temp << [ phase_month, 0]
              @total_stats << [ phase_month, user_recipes_count, user_choiced_recipes_count, more_recipes_users_count, users_count ]
            elsif user_index > 0 && user_recipes_count > 0
              last_most_user_stats = @user_stats_group[most_temp[m][1]][m]
              if user_recipes_count > last_most_user_stats[1] || (user_recipes_count == last_most_user_stats[1] && user_choiced_recipes_count > last_most_user_stats[2])
                is_most = true
                last_most_user_stats[3] = false
                most_temp[m][1] = user_index
              elsif user_recipes_count == last_most_user_stats[1] && user_choiced_recipes_count == last_most_user_stats[2]
                is_most = true
              end

              last_most_user_stats = @user_stats_group[most_choiced_temp[m][1]][m]
              if user_choiced_recipes_count > last_most_user_stats[2] || (user_choiced_recipes_count == last_most_user_stats[2] && user_recipes_count > last_most_user_stats[1])
                is_most_choiced = true
                last_most_user_stats[4] = false
                most_choiced_temp[m][1] = user_index
              elsif user_choiced_recipes_count == last_most_user_stats[2] && user_recipes_count == last_most_user_stats[1]
                is_most_choiced = true
              end

              @total_stats[m][1] += user_recipes_count
              @total_stats[m][2] += user_choiced_recipes_count
              @total_stats[m][3] += more_recipes_users_count
              @total_stats[m][4] += users_count
            end

            user_stats << [ phase_month, user_recipes_count, user_choiced_recipes_count, is_most, is_most_choiced ]

            if phase_month == stat_to.strftime("%Y-%m")
              if (user_recipes_count_sum >= 80) || (user_more_recipes_months_count >= 10)
                more_recipes_users_count_total = 1
              end

              is_most_sum = false
              is_most_choiced_sum = false

              if user_index == 0
                is_most_sum = true
                most_temp << [ 'sum', 0 ]
                most_choiced_temp << [ 'sum', 0]
                @total_stats << [ 'sum', user_recipes_count_sum, user_choiced_recipes_count_sum, more_recipes_users_count_total ]
              elsif user_index > 0
                last_most_sum_stats = @user_stats_group[most_temp.last[1]].last
                if user_recipes_count_sum > last_most_sum_stats[1] || (user_recipes_count_sum == last_most_sum_stats[1] && user_choiced_recipes_count_sum > last_most_sum_stats[2])
                  is_most_sum = true
                  last_most_sum_stats[4] = false
                  most_temp.last[1] = user_index
                elsif user_recipes_count_sum == last_most_sum_stats[1] && user_choiced_recipes_count_sum == last_most_sum_stats[2]
                  is_most_sum = true
                end

                last_most_sum_stats = @user_stats_group[most_choiced_temp.last[1]].last
                if user_choiced_recipes_count_sum > last_most_sum_stats[2] || (user_choiced_recipes_count_sum == last_most_sum_stats[2] && user_recipes_count_sum > last_most_sum_stats[1])
                  is_most_choiced_sum = true
                  last_most_sum_stats[5] = false
                  most_choiced_temp.last[1] = user_index
                elsif user_choiced_recipes_count_sum == last_most_sum_stats[2] && user_recipes_count_sum == last_most_sum_stats[1]
                  is_most_choiced_sum = true
                end

                @total_stats.last[1] += user_recipes_count_sum
                @total_stats.last[2] += user_choiced_recipes_count_sum
                @total_stats.last[3] += more_recipes_users_count_total
              end

              user_stats << [ 'sum', user_recipes_count_sum, user_choiced_recipes_count_sum, user_more_recipes_months_count, is_most_sum, is_most_choiced_sum ]

              break
            else
              phase_start += 1.month
            end
          end
          @user_stats_group << user_stats
          user_index += 1
        end
        @total_stats.last[4] = @user_recipes_groups.size
        @user_stats_group.sort! { |a, b| a[0] <=> b[0] }
      else
        flash[:notice] = "对不起, 没有得到统计数据!"
      end
    else
      flash[:notice] = "对不起, 你没有访问权限!"
      redirect_to root_url
    end
#    [[111,['2009-08',25,10],['2009-09',25,10],['sum',50,20]],
#     [222,['2009-08',25,10],['2009-09',25,10],['sum',50,20]],
#     [nil,['2009-08',25,10],['2009-09',25,10],['sum',50,20]]
  end

  # 食谱PK赛
  def pk_game
    game = params[:game]
    round = params[:round]
    @pk_groups = pk_game_groups(game, round)

    round_titles = %w[一 二 三 四 五 六 七 八 九 十]
    info = "美味无敌快乐PK赛——#{pk_game_title(game)}（第#{round_titles[round.to_i - 1]}轮）"
    set_page_title(info)
		set_block_title(info)

    @meta_description = "这是#{info}的信息，包括这一轮的对阵形势和投票结果等内容。"
  end
  
  private
  
  def set_tag_list
    if !params[:recipe][:tag_list].strip.blank?
    	params[:recipe][:tag_list] = clean_tags(params[:recipe][:tag_list])
    end
  end
  
  def load_recipe(user = nil)
  	if user && !user.is_role_of?('admin')
 			recipe = user.recipes.find(@self_id)
 		else
 			recipe = Recipe.find(@self_id)
 		end
    if (user && user.is_role_of?('admin')) || params[:action] == 'destroy' || recipe_accessible?(recipe)
#    if params[:action] == 'destroy' || recipe.accessible?(user)
 			@recipe = recipe
 		end
  end
  
  ## load love recipes of the user 加载爱心食谱数据
  def load_love_recipes(user = nil)
    if (@action_flag == 1)
      begin
        @love_recipes_set = CACHE.get('overview_love_recipes_set')
      rescue Memcached::NotFound
        @love_recipes_set = love_recipes(user, '21')
        CACHE.set('overview_love_recipes_set',@love_recipes_set)
      end
    else
      @love_recipes_set = love_recipes(user, '21')
    end
####    @love_recipes_set = love_recipes(user, '21')
    @love_recipes_set_count = @love_recipes_set.size
  end
  
  def load_love_users(user = nil)
    if (@action_flag == 1)
      begin
        @love_users_set = CACHE.get('overview_love_users_set')
      rescue Memcached::NotFound
        @love_users_set = love_users(user)
        CACHE.set('overview_love_users_set',@love_users_set)
      end
    else
      @love_users_set = love_users(user)
    end
####    @love_users_set = love_users(user)
    @love_users_set_count = @love_users_set.size
  end
  ## end
  
  def load_recipes_set(user = nil)
    if (@action_flag == 1)
      if @current_user
        begin
         @recipes_set = CACHE.get('overview_recipes_set')
        rescue Memcached::NotFound
          order = @order ? @order : 'published_at DESC, created_at DESC'
          @recipes_set = filtered_recipes(user, params[:filter], @recipes_limit, order)
          CACHE.set('overview_recipes_set',@recipes_set)
        end
      else
        begin
         @recipes_set = CACHE.get('overview_all_recipes_set')
        rescue Memcached::NotFound
          order = @order ? @order : 'published_at DESC, created_at DESC'
          @recipes_set = filtered_recipes(user, params[:filter], @recipes_limit, order)
          CACHE.set('overview_all_recipes_set',@recipes_set)
        end
      end      
    else
      order = @order ? @order : 'published_at DESC, created_at DESC'
      @recipes_set = filtered_recipes(user, params[:filter], @recipes_limit, order)
    end
####    order = @order ? @order : 'published_at DESC, created_at DESC'
####    @recipes_set = filtered_recipes(user, params[:filter], @recipes_limit, order)
    @recipes_set_count = @recipes_set.size
  end
  
  def load_choice_recipes(user = nil)
    if (@action_flag == 1)
      if @current_user
        begin
          @choice_recipes = CACHE.get('overview_choice_recipes')
        rescue Memcached::NotFound
          @choice_recipes = roles_recipes(user, '11', 12)
          CACHE.set('overview_choice_recipes',@choice_recipes,1800)
        end
      else
        begin
          @choice_recipes = CACHE.get('overview_all_choice_recipes')
        rescue Memcached::NotFound
          @choice_recipes = roles_recipes(user, '11', 12)
          CACHE.set('overview_all_choice_recipes',@choice_recipes,1800)
        end
      end
      
    else
      @choice_recipes = roles_recipes(user, '11', 12)
    end
####    @choice_recipes = roles_recipes(user, '11', 12)
  end
  
#  def load_random_recipes(user = nil)
#  	@random_recipes = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 12, 'RAND()')
#  end
  
  def load_reviews_set(user = nil)
  	# @reviews_set = reviews_for(user, 'Recipe', review_conditions('Recipe', @self_id), recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)))
  	if (@action_flag == 1)
      begin
        @reviews_set = CACHE.get('overview_reviews_set')
      rescue Memcached::NotFound
        @reviews_set = reviewable_type_reviews('Recipe')[0..19]
        CACHE.set('overview_reviews_set',@reviews_set)
      end
    else
      @reviews_set = reviewable_type_reviews('Recipe')[0..19]
    end
####    @reviews_set = reviewable_type_reviews('Recipe')[0..19]
    @reviews_set_count = @reviews_set.size
  end
  
  def load_tags_set(user = nil)
    if (@action_flag == 1)
      begin
        @tags_set = CACHE.get('overview_tags_set')
      rescue Memcached::NotFound
        @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
        CACHE.set('overview_tags_set',@tags_set)
      end
    else
      @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
    end
####    @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
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
