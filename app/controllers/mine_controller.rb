class MineController < ApplicationController
	
	before_filter :protect
	
	def overview
  	load_my_recipes
  	@recipes = @recipes_set[0..MATRIX_ITEMS_COUNT_PER_PAGE_S - 1]
  	
  	load_my_reviews
  	@reviews = @reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
	 	
	 	info = "我的#{SITE_NAME_CN}"
		set_page_title(info)	
	end
	
	def reviews
		load_my_reviews
  	
	 	@reviews = @reviews_set.paginate :page => params[:page], 
 															 			 :per_page => LIST_ITEMS_COUNT_PER_PAGE_S
 															 			   	
  	info = "我的#{REVIEW_CN}(#{@reviews_set_count})"
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
	
	end
	
	private
	
	def load_my_recipes
		@recipes_set = recipes_for(@current_user, false, false, nil, nil, 'created_at DESC')
		@recipes_set_count = @recipes_set.size
	end
	
	def load_my_reviews
		@reviews_set = reviews_for(@current_user, nil, nil, nil, nil, 'created_at DESC')
		@reviews_set_count = @reviews_set.size
	end
end
