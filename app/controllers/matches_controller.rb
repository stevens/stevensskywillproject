class MatchesController < ApplicationController
  
  before_filter :protect, :except => [:index, :show, :overview, :profile, :help]
	before_filter :store_location_if_logged_in, :only => [:mine]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show, :overview, :profile]
  before_filter :set_system_notice, :only => [:show, :index, :overview, :profile]
  
  def help
		info = "#{MATCH_CN}指南"
		set_page_title(info)
		set_block_title(info)
  end
  
  def set_status
  	load_match(@current_user)
  	
  	status = Code.find_by_codeable_type_and_name('match_status', params[:status]).code
  	
  	if @match.update_attribute(:status, status)
	  	case params[:status]
	  	when 'doing'
	  		@notice = "你已经启动了这#{unit_for('Match')}#{MATCH_CN}!"
	  	when 'done'
	  		@notice = "你已经关闭了这#{unit_for('Match')}#{MATCH_CN}!"
	  	end
	  	
	  	respond_to do |format|
	  		format.html do
	  			flash[:notice] = @notice
	  			redirect_to @match
	  		end
	  	end
	  end
  end
  
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => params[:filter] }
      else
		    load_matches_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{MATCH_CN}"
				set_page_title(info)
				set_block_title(info)
				
		  	# @show_todo = true
		  	# @show_favorite = true
				
      	format.html
      end
    end
  end
  
  def show
    load_match
    
		load_matches_set(@match.user)
		
		@match_index = @matches_set.index(@match)											
		
		# show_sidebar
		
		match_title = item_title(@match)
		match_username = user_username(@match.user, true, true)
		match_link_url = item_first_link(@match)
		
		info = "#{MATCH_CN}详情 - #{match_title}"
		set_page_title(info)
		set_block_title(info)
		@meta_description = "这是#{match_title}的#{MATCH_CN}详情信息, 来自#{match_username}. "
		set_meta_keywords
		@meta_keywords = [ match_title, match_username, match_link_url ] + @meta_keywords
		@meta_keywords << @match.tag_list if !@match.tag_list.blank?

    respond_to do |format|
      format.html
    end
  end
  
  def new
  	if @current_user.is_role_of?('admin')
	    @match = @current_user.matches.build
		end
    
    info = "新#{MATCH_CN}"
		set_page_title(info)
		set_block_title(info)
    
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    load_match(@current_user)
    
 		match_title = item_title(@match)
    
 		info = "#{EDIT_CN}#{MATCH_CN} - #{match_title}"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html
    end
  end
  
  def create
    set_time
    set_tag_list

    @match = @current_user.matches.build(params[:match])
    @match.status = '10'
    @match.is_draft = '0'
    @match.self_vote = '1'
    @match.privacy = '10'
		@match.organiger_type = 'User'
		@match.organiger_id = @current_user.id
		@match.published_at = Time.now
		item_client_ip(@match)
		
    ActiveRecord::Base.transaction do    
			if @match.save
				reg_homepage(@match)
				after_create_ok
			else
				after_create_error
			end
		end
  end
  
  def update
    load_match(@current_user)
    params[:match][:original_updated_at] = Time.now

    set_time
    set_tag_list
    
    ActiveRecord::Base.transaction do
		  if @match.update_attributes(params[:match])
				reg_homepage(@match, 'update')
				after_update_ok
		  else
				after_update_error
		  end
	  end
  end
  
  def destroy
    load_match(@current_user)
		
		ActiveRecord::Base.transaction do
			if @match.destroy
				reg_homepage(@match, 'destroy')
				after_destroy_ok
			end
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
  	
  	@entries_set = @match.entries.find(:all, :order => 'RAND()')
  	vll = @match.votes_lower_limit
  	if vll && vll > 0
	  	@highest_voted_entries = @match.entries.find(:all, :limit => 20, :order => 'total_votes DESC, votes_count DESC', 
	  																							 :conditions => "entries.votes_count > #{vll}")
	  else
  		@highest_voted_entries = (@entries_set.sort { |a,b| [ b.total_votes, b.votes_count ] <=> [ a.total_votes, a.votes_count ] })[0..19]
  	end
  	@entriables_set = entriables_for(@entries_set[0..17])
		@player_users_set = match_actor_users(@match.players.find(:all, :order => 'RAND()'))
  	
  	# 获得也在参赛的伙伴们
  	if @current_user
	  	load_contactors_set
	  	if @contactors_set_count > 0
	  		@player_contactors_set = @player_users_set & @contactors_set
	  	end
  	end
  	
  	show_sidebar
  	
		match_title = item_title(@match)
		match_username = user_username(@match.user, true, true)
		match_link_url = item_first_link(@match, true)
		
		info = "#{MATCH_CN} - #{match_title}"
		set_page_title(info)
		@meta_description = "这是#{match_title}的#{MATCH_CN}信息, 来自#{match_username}. "
		set_meta_keywords
		@meta_keywords = [ match_title, match_username, match_link_url ] + @meta_keywords
		@meta_keywords << @match.tag_list if !@match.tag_list.blank?
  	
    respond_to do |format|
  		format.html do
  			log_count(@match)
  		end
    end
  end
  
  def mine
    load_matches_set(@current_user)
    
  	@show_photo_todo = true
  	@show_todo = true
  	@show_manage = true
		
		info = "#{username_prefix(@current_user)}#{MATCH_CN}"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => 'matches/index' }
    end
  end
  
  private
  
	def set_meta_keywords
		@meta_keywords = [ '比赛', '大奖赛', '美食大赛', '美食大奖赛', DESCRIPTION_CN, '介绍', '时间', '赛程', '赛程时间', '赛程安排', '奖项', '奖品', '奖项设置', '规则', '选手', '作品', '投票', '获奖', '获奖名单' ]
	end
  
  def set_tag_list
    if !params[:match][:tag_list].strip.blank?
    	params[:match][:tag_list] = clean_tags(params[:match][:tag_list])
    end
  end
  
  def set_time
    params[:match][:enrolling_start_at] = params[:match][:start_at] if params[:match][:enrolling_start_at].blank?
    params[:match][:collecting_start_at] = params[:match][:start_at] if params[:match][:collecting_start_at].blank?
    params[:match][:voting_start_at] = params[:match][:start_at] if params[:match][:voting_start_at].blank?
    params[:match][:end_at] = params[:match][:end_at].to_time.end_of_day if !params[:match][:end_at].blank?
    if params[:match][:enrolling_end_at].blank?
    	params[:match][:enrolling_end_at] = params[:match][:end_at]
    else
    	params[:match][:enrolling_end_at] = params[:match][:enrolling_end_at].to_time.end_of_day
    end
    if params[:match][:collecting_end_at].blank?
    	params[:match][:collecting_end_at] = params[:match][:end_at]
    else
    	params[:match][:collecting_end_at] = params[:match][:collecting_end_at].to_time.end_of_day
    end
    if params[:match][:voting_end_at].blank?
    	params[:match][:voting_end_at] = params[:match][:end_at]
    else
    	params[:match][:voting_end_at] = params[:match][:voting_end_at].to_time.end_of_day
    end
  end
  
  def load_match(user = nil)
  	if user
			@match = user.matches.find(@self_id)
		else
			@match = Match.find(@self_id)
		end
  end
  
  def load_matches_set(user = nil)
  	@matches_set = filtered_matches_set(user, params[:filter])
  	@matches_set_count = @matches_set.size
  end
  
	def load_contactors_set(user = @current_user)
		@contactors_set = contactors_for(contacts_for(user, contact_conditions('1', '3'), nil, 'RAND()'))
		@contactors_set_count = @contactors_set.size
	end
	
  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "你已经成功#{CREATE_CN}了1#{@self_unit}新#{@self_name}, 快去#{ADD_CN}几#{unit_for('Photo')}漂亮的#{PHOTO_CN}吧!"	
				redirect_to @match
			end
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				info = "新#{MATCH_CN}"	
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
		end
  end
  
  def after_update_ok
  	respond_to do |format|
			format.html do 
				flash[:notice] = "你已经成功#{UPDATE_CN}了1#{@self_unit}#{@self_name}!"	
				redirect_to @match
			end
		end
  end
  
  def after_update_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{@self_name}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				info = "#{EDIT_CN}#{MATCH_CN} - #{@match.title}"
				set_page_title(info)
				set_block_title(info)
				
				render :action => "edit"
				clear_notice
			end
		end
  end
  
  def after_destroy_ok
		respond_to do |format|
		  format.html do
		  	flash[:notice] = "你已经成功#{DELETE_CN}了1#{@self_unit}#{@self_name}!"	
		  	redirect_to url_for(:controller => 'matches', :action => 'mine', :filter => params[:filter], :page => params[:page])
		  end
		end
  end
  
end
