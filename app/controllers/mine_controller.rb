class MineController < ApplicationController
	
	before_filter :protect
	
	def overview
	 	info = "我的#{SITE_NAME_CN}"
		set_page_title(info)	
	end
	
	def reviews
		@reviews_set = reviews_for(@current_user, nil, nil, nil, nil, 'created_at DESC')
		@reviews_set_count = @reviews_set.size
  	
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
	
end
