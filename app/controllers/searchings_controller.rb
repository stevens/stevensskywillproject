class SearchingsController < ApplicationController

	# before_filter :protect
	before_filter :clear_location_unless_logged_in
	before_filter :load_searchable_type
	
	def search
  	if @searchable_type && params[:search_keywords]
  		keywords_line = text_squish(params[:search_keywords])
  		if !keywords_line.blank?
		  	search_id = keywords_line_to_search_id(keywords_line)
	  		redirect_to :searchable_type => @searchable_type.downcase, :action => 'show', :id => search_id
	  	else
				flash[:notice] = "#{SORRY_CN}, 你还没有#{INPUT_CN}#{SEARCH_CN}条件!"
				
				info = "#{name_for(@searchable_type)}#{SEARCH_CN}" 
				set_page_title(info)
				set_block_title(info) 	
	  	end
  	end
	end
	
	def show
  	if params[:id]
  		@keywords = search_id_to_keywords(params[:id])
  		if @keywords != []
		  	@keywords_line = @keywords.join(' ')
	  	
			 	load_searchables_set
			 	
			 	info = "#{name_for(@searchable_type)}#{SEARCH_CN} - #{@keywords_line} (#{@searchables_set_count})"
			 	
				if @searchables_set_count > 0
					flash[:notice] = "共有#{@searchables_set_count}#{unit_for(@searchable_type)}#{name_for(@searchable_type)}符合#{SEARCH_CN}条件......"
				else
					flash[:notice] = "#{SORRY_CN}, 没有符合#{SEARCH_CN}条件的#{name_for(@searchable_type)}!"
				end
			end
		end

		set_page_title(info)
		set_block_title(info)
 		
    respond_to do |format|
     	format.html do
     		render :template => "#{controller_name(@searchable_type)}/index"
     	end
      format.xml  { render :xml => @searchables_set }
    end
    clear_notice
	end
	
	private
	
	def load_searchable_type
		if params[:searchable_type]
			@searchable_type = params[:searchable_type].camelize
		end
	end
	
	def load_searchables_set(user = nil)
		case @searchable_type
		when 'Recipe'
			@searchables_set = searchables_for(user, @searchable_type, @keywords, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), nil, true, nil, 'published_at DESC, created_at DESC')
			@recipes_set = @searchables_set
		end
		@searchables_set_count = @searchables_set.size
	end

end
