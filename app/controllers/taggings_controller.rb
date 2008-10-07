class TaggingsController < ApplicationController
	
	before_filter :protect, :except => [:index]
	before_filter :clear_location_unless_logged_in, :only => [:index]
	before_filter :load_taggable_type
	
	def index 		
    respond_to do |format|
      if @user && @user == @current_user
      	if @taggable_type
      		format.html { redirect_to :action => 'mine', :taggable_type => @taggable_type.downcase }
      	else
      		format.html { redirect_to :action => 'mine' }
      	end
      else
		  	load_tags_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{name_for(@taggable_type)}#{TAG_CN} (#{@tags_set_count})#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)
		
      	format.html # index.html.erb
      end
      format.xml  { render :xml => @tags }
    end
	end
	
	def show
  	if params[:id]
		 	load_taggables_set
		 	
		 	info = "#{name_for(@taggable_type)}#{TAG_CN} - #{params[:id]} (#{@taggables_set_count})"
			set_page_title(info)
			set_block_title(info)
	 		
	 		load_tags_set
	 		
	 		show_sidebar
	 		
	    respond_to do |format|
	     	format.html do
	     		flash[:notice] = "共有#{@taggables_set_count}#{unit_for(@taggable_type)}#{name_for(@taggable_type)}包含这个#{TAG_CN}......"
	     		render :template => "#{controller_name(@taggable_type)}/index"
	     	end
	      format.xml  { render :xml => @taggables }
	    end
	    clear_notice
		end
	end
	
	def mine
		load_tags_set(@current_user)
		
  	info = "#{username_prefix(@current_user)}#{name_for(@taggable_type)}#{TAG_CN} (#{@tags_set_count})"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "taggings/index" }
      format.xml  { render :xml => @tags }
    end
	end
	
	private
	
	def load_taggable_type
		if @parent_type
			@taggable_type = @parent_type
		elsif params[:taggable_type]
			@taggable_type = params[:taggable_type].camelize
		else
			@taggable_type = 'Recipe'
		end
	end
	
	def load_tags_set(user = nil)
		if user && !@taggable_type
			@recipe_tags_set = tags_for(user, 'Recipe')
			@tags_set = @recipe_tags_set
	  	@custom_tags_set = tags_for(user, 'Recipe', nil, TAG_COUNT_AT_LEAST, TAG_COUNT_AT_MOST, nil, order = 'count DESC')
		else
			@tags_set = tags_for(user, @taggable_type, @taggable_id)
			@custom_tags_set = tags_for(user, @taggable_type, @taggable_id, TAG_COUNT_AT_LEAST, TAG_COUNT_AT_MOST, nil, order = 'count DESC')
		end
		@tags_set = sort_by_gbk(@tags_set)
		@tags_set_count = @tags_set.size
	end
	
	def load_taggables_set(user = nil)
		case @taggable_type
		when 'Recipe'
			@taggables_set = taggables_for(user, @taggable_type, params[:id], recipe_conditions({:photo_required => true, :status => '1', :privacy => '11', :is_draft => '0'}))
		end
		@taggables_set_count = @taggables_set.size if @taggables_set
	end
	
end
