class SearchingsController < ApplicationController

	# before_filter :protect
	before_filter :clear_location_unless_logged_in
	before_filter :load_searchable_type
	
	def search
  	if @searchable_type && params[:search_keywords]
  		keywords_line = str_squish(params[:search_keywords])
  		if !keywords_line.blank?
		  	search_id = keywords_line_to_search_id(keywords_line)
	  		redirect_to :searchable_type => @searchable_type.downcase, :action => 'show', :id => search_id
	  	else
				flash[:notice] = "#{SORRY_CN}, 你还没有#{INPUT_CN}#{SEARCH_CN}条件!"
				
				info = "#{name_for(@searchable_type)}#{SEARCH_CN}" 
				set_page_title(info)
				set_block_title(info)
				render :action => 'search'
				clear_notice 	
	  	end
  	end
	end
	
	def show
  	if params[:id]
  		@keywords = search_id_to_keywords(params[:id])
  		if @keywords != []
		  	@keywords_line = @keywords.join(' ')
	  	
			 	load_searchables_set
			 	
			 	searchable_type_name = @searchable_type == 'User' ? PEOPLE_CN : name_for(@searchable_type)
			 	
			 	info = "#{searchable_type_name}#{SEARCH_CN} - #{@keywords_line} (#{@searchables_set_count})"
			 	
				if @searchables_set_count > 0
					flash[:notice] = "共有#{@searchables_set_count}#{unit_for(@searchable_type)}#{searchable_type_name}符合#{SEARCH_CN}条件......"
				else
					flash[:notice] = "#{SORRY_CN}, 没有符合#{SEARCH_CN}条件的#{searchable_type_name}!"
				end
			end
		end

		set_page_title(info)
		set_block_title(info)
		
		if ['Recipe'].include? @searchable_type
			load_tags_set	
	 		show_sidebar
	 	end
 		
    respond_to do |format|
     	format.html do
     		render :template => "#{controller_name(@searchable_type)}/index"
     	end
      # format.xml  { render :xml => @searchables_set }
    end
    clear_notice
	end

  # 联通淘宝等网站搜索相关商品，将搜索结果展示在服务区
  def searching_shop_items
    where = 'taobao'
    limit = 4
    item_category = shop_item_category(where, params[:searchable_type], params[:q])
    shop_items_set = shop_items_searched(where, { :q => params[:q], :cid => item_category })
    if shop_items_set && shop_items_set.size > 0
      shop_items_set = shop_items_set.sort_by {rand}
    else
      shop_items_set = shop_items_searched(where, { :q => params[:q] }).sort_by {rand}
    end
    @shop_items = shop_items_set[0..limit-1]
    respond_to do |format|
			format.js do
				render :update do |page|
          page.hide "#{params[:service_id]}"
          page.replace_html "#{params[:service_id]}",
                            :partial => 'searchings/shop_items_block',
                            :locals => { :items => @shop_items,
                                        :options => { :service_id => params[:service_id] }}
          page.visual_effect :slide_down, "#{params[:service_id]}"
				end
			end
  	end
  end
	
	private
	
	def load_searchable_type
		if params[:searchable_type]
			@searchable_type = params[:searchable_type].camelize
		end
	end

	def load_tags_set(user = nil)
		case @searchable_type
		when 'Recipe'
			@tags_set = tags_for(user, @searchable_type, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
		end
		@tags_set_count = @tags_set.size
	end
	
	def load_searchables_set(user = nil)
		case @searchable_type
		when 'Recipe'
			@searchables_set = searchables_for(user, @searchable_type, @keywords, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), nil, true, nil, 'published_at DESC, created_at DESC')
			@recipes_set = @searchables_set
		when 'User'
			@searchables_set = searchables_for(nil, @searchable_type, @keywords, user_conditions, nil, true, nil, 'activated_at DESC, created_at DESC')
			@users_set = @searchables_set
		end
		@searchables_set_count = @searchables_set.size if @searchables_set
	end

end
