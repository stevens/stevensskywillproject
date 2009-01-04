class MatchActorsController < ApplicationController
	
	before_filter :protect, :except => [:index]
	before_filter :store_location_if_logged_in, :only => [:index]
	before_filter :clear_location_unless_logged_in, :only => [:index]
  before_filter :load_current_filter, :only => [:index]
  
  def index

  end
  
  def new
  	redirect_to match_profile_path(@parent_obj)
  end
  
  def create
  	load_match_actor_role
  	
    @match_actor = @parent_obj.match_actors.build
		@match_actor.user_id = @current_user.id
		@match_actor.roles = @match_actor_role
		
		unless @parent_obj.match_actors.find_by_user_id_and_roles(@current_user.id, @match_actor_role)
			respond_to do |format|
				format.js do
					render :update do |page|
						if @match_actor.save
							if @match_actor_role == '1'
								@notice = "你已经报名参加了这#{unit_for('Match')}#{MATCH_CN}!"
								page.replace_html "flash_wrapper", 
																	:partial => "/layouts/flash",
														 			:locals => { :notice => @notice }
								page.show "flash_wrapper"
								page.replace_html "match_enroll_bar", 
																	:partial => "/matches/match_enroll_bar", 
																  :locals => { :item => @parent_obj }
							end
						end
					end
				end
			end
		end
  end
  
  def destroy
  	load_match_actor
  	
  	if @match_actor
  		@match_actor_role = @match_actor.roles
  		respond_to do |format|
				format.js do
					render :update do |page|
  					if @match_actor.destroy
  						if @match_actor_role == '1'
								@notice = "你已经退出了这#{unit_for('Match')}#{MATCH_CN}!"
								page.replace_html "flash_wrapper", 
																	:partial => "/layouts/flash",
														 			:locals => { :notice => @notice }
								page.show "flash_wrapper"
								page.replace_html "match_enroll_bar", 
																	:partial => "/matches/match_enroll_bar", 
																  :locals => { :item => @parent_obj }
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
  	@match_actor = MatchActor.find(@self_id)
  end
  
end
