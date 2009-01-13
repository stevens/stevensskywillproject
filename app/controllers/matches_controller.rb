class MatchesController < ApplicationController
  
  before_filter :protect, :except => [:index, :show, :overview, :profile]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview, :profile]
	before_filter :load_current_filter, :only => [:index, :mine]
  before_filter :set_system_notice, :only => [:show, :index, :overview]
  
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
  	
  	if @current_user
  		if  @player = @match.find_actor(@current_user, '1')
  			@submitted_entriables_set = entriables_for(@match.find_player_entries(@current_user))
  		end
  		@voted_entriables_set = entriables_for(voteables_for(@match.find_voter_entries(@current_user)))
  	end
  	
  	@entriables_set = entriables_for(@match.entries.find(:all, :limit => 12, :order => 'RAND()'))
		@player_users_set = match_actor_users(@match.players.find(:all, :limit => 12, :order => 'RAND()'))
  	
    respond_to do |format|
		 	log_count(@match)
		 	
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
  		match_actors = user.match_actors.find(:all)
  		joined_matches_set = joined_matches(match_actors)
  	else
  		joined_matches_set = []
  	end
  	created_matches_set = matches_for(user)
  	@matches_set = created_matches_set | joined_matches_set
  	@matches_set_count = @matches_set.size
  end
  
end
