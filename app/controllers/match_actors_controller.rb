class MatchActorsController < ApplicationController
	
	before_filter :protect, :except => [:index]
	before_filter :clear_location_unless_logged_in, :only => [:index]
  
  def index
  	@match = @parent_obj
  	load_match_actor_role
		load_match_actors_set
		@match_actor_users_set = match_actor_users(@match_actors_set)
  	
    respond_to do |format|
    	format.html do
    		actor_title = Code.find_by_codeable_type_and_code('match_actor_role', @match_actor_role).title
		  	info = "#{actor_title} (#{@match_actors_set_count})#{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)    	
    	end
    end 
  end
  
  def new
  	redirect_to item_first_link(@parent_obj, true)
  end
  
  def create
  	load_match_actor_role
  	
    @match_actor = @parent_obj.match_actors.build
		@match_actor.user_id = @current_user.id
		@match_actor.roles = @match_actor_role
		
		unless @parent_obj.find_actor(@current_user, @match_actor_role)
			if @match_actor.save
				if @match_actor_role == '1'
					@notice = "你已经报名参加了这#{unit_for('Match')}#{MATCH_CN}, 祝你取得好成绩!"
					respond_to do |format|
						format.js do
							render :update do |page|
								flash[:notice] = @notice
								page.redirect_to item_first_link(@parent_obj, true)
							end
						end
					end
				end
			end
		end
  end
  
  def destroy
  	load_match_actor
  	
		respond_to do |format|
			format.js do
				render :update do |page|
			  	if @match_actor
			  		if @parent_obj.player_has_entries?(@current_user)
			  			@notice = "#{SORRY_CN}, 由于你还有作品正在参赛, 所以目前还不能退出这#{unit_for('Match')}#{MATCH_CN}!<br />
			  								 如果你打算退出#{MATCH_CN}, 请先#{CANCLE_CN}你的所有#{ENTRY_CN}..."
							page.replace_html "flash_wrapper", 
																:partial => "/layouts/flash",
													 			:locals => { :notice => @notice }
							page.show "flash_wrapper"
			  		else
				  		match_actor_role = @match_actor.roles
							if @match_actor.destroy
								if match_actor_role == '1'
									@notice = "你已经退出了这#{unit_for('Match')}#{MATCH_CN}!"
									flash[:notice] = @notice
									page.redirect_to item_first_link(@parent_obj, true)
								end
							end
						end
					end
				end
			end
		end
  end
  
  private
  
  def load_match_actor_role
  	@match_actor_role = Code.find_by_codeable_type_and_name('match_actor_role', params[:match_actor_role]).code
  end
  
  def load_match_actor
  	@match_actor = @parent_obj.match_actors.find_by_id(@self_id)
  end
  
  def load_match_actors_set
  	@match_actors_set = @parent_obj.match_actors.find(:all, :conditions => { :roles => @match_actor_role })
  	@match_actors_set_count = @match_actors_set.size
  end
  
end
