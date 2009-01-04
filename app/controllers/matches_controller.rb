class MatchesController < ApplicationController
  
  before_filter :protect, :except => [:index, :show, :overview, :profile]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview, :profile]
	before_filter :load_current_filter, :only => [:index, :mine]
  
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => @current_filter }
      else
		    load_matches_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{MATCH_CN}"
				set_page_title(info)
				set_block_title(info)
				
		  	# @show_todo = true
		  	# @show_favorite = true
				
      	format.html # index.html.erb
      end
      # format.xml  { render :xml => @matches_set }
    end
  end
  
  def show
    load_match
    
		load_matches_set(@match.user)
		
		@match_index = @matches_set.index(@match)											
		
		# show_sidebar
		
		info = "#{MATCH_CN}详情 - #{@match.title}"
		set_page_title(info)
		set_block_title(info)
		# @meta_description = "这是#{@recipe.title}的#{RECIPE_CN}（菜谱）信息, 来自#{@recipe.user.login}. "
		# @meta_keywords = [@recipe.title, @recipe.user.login, DESCRIPTION_CN, INGREDIENT_CN, DIRECTION_CN, TIP_CN]
		# @meta_keywords << @recipe.tag_list

    respond_to do |format|
      format.html # show.html.erb
      # format.xml  { render :xml => @match }
    end
  end
  
  def profile
  	load_match
  	
  	load_matches_set
  	
    respond_to do |format|
		 	# log_count(@user)
		 	
		 	info = "#{MATCH_CN} - #{@match.title}"
			set_page_title(info)
			
			# show_sidebar
			
  		format.html # profile.html.erb
    end
  end
  
  def mine
    load_matches_set(@current_user)
    
  	# @show_photo_todo = true
  	# @show_todo = true
  	# @show_manage = true
		
		info = "#{username_prefix(@current_user)}#{MATCH_CN}"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "matches/index" }
      # format.xml  { render :xml => @matches_set }
    end
  end
  
  private
  
  def load_match
		@match = Match.find(@self_id)
  end
  
  def load_matches_set(user = nil)
  	if user
  		created_matches_set = user.matches.find(:all)
  		match_actors = MatchActor.find(:all, :conditions => { :user_id => user.id, :roles => '1' })
  		enrolled_matches_set = []
  		for match_actor in match_actors
  			enrolled_matches_set << match_actor.match
  		end
  		@matches_set = created_matches_set | enrolled_matches_set
  	else
  		@matches_set = Match.find(:all)
  	end
  	@matches_set_count = @matches_set.size
  end
  
end
