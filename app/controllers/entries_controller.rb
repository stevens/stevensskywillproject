class EntriesController < ApplicationController
	
  before_filter :protect, :except => [:index, :show]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	
	def index
		load_match
		load_entries_set
		@entriables_set = entriables_for(@entries_set)
		
    respond_to do |format|
    	format.html do
		  	info = "#{ENTRY_CN} #{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)    	
    	end
    end 
	end
	
	def new
		if item_manageable?(@parent_obj) && @parent_obj.entriable?
			load_matches_set
			if @matches_set_count > 0
				@entry = @parent_obj.entries.build
			else
				@notice = "#{SORRY_CN}, 目前还没有你可以参加的#{MATCH_CN}!"
			end
		else
			@notice = "#{SORRY_CN}, 这#{unit_for(@parent_type)}#{name_for(@parent_type)}目前还不能参加#{MATCH_CN}!"
		end
		
		info = "新#{ENTRY_CN} [#{name_for(@parent_type)}]"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html do
      	flash[:notice] = @notice
      	render :action => 'new'
      	clear_notice
      end
    end
	end
	
	def create
    @entry = @parent_obj.entries.build(params[:entry])
		@entry.user_id = @current_user.id
		@entry.total_votes = 0
		@entry.votes_count = 0
		
		if @entry.match_id && (match = Match.find_by_id_and_entriable_type(@entry.match_id, @parent_type))
			current = Time.now
			if match.doing?(current) && (match.collect_time_status(current)[1] == 'doing') && !match.find_entry(@parent_obj)			
				@remain_epp = match.player_remain_entries_count(@current_user)
				if !@remain_epp || @remain_epp > 0
					ActiveRecord::Base.transaction do
						if @entry.save
							if @parent_obj.update_attribute(:match_id, @entry.match_id)
								after_create_ok
							else
								after_create_error
							end
						else
							after_create_error
						end
					end
				else
					after_create_error
				end
			else
				after_create_error
			end
		else
			after_create_error
		end
	end
	
	def destroy
		load_entry
		
		current = Time.now
		
		if @entry && item_manageable?(@entry) && @parent_obj.doing?(current)
			@entriable = @entry.entriable
			if item_manageable?(@entriable)
				ActiveRecord::Base.transaction do
					if @entry.destroy
						if @entriable.update_attribute(:match_id, nil)
							after_destroy_ok
						end
					end
				end
			end
		end
	end
	
	private
	
	def load_entry
		@entry = @parent_obj.entries.find_by_id(@self_id)
	end
	
	def load_match
		@match = @parent_obj
	end
	
  def load_entries_set(user = @current_user)
		@entries_set = filtered_entries(@parent_obj, user, params[:filter])
  	@entries_set_count = @entries_set.size
  end
	
	def	load_matches_set(user = @current_user)
		if user
  		match_actors = user.match_actors.find(:all, :conditions => { :roles => '1' })
  		matches_set = joined_matches(match_actors)
  		@matches_set = []
  		for match in matches_set
  			current = Time.now
  			if match.doing?(current) && (match.collect_time_status(current)[1] == 'doing') && !match.find_entry(@parent_obj)
  				remain_epp = match.player_remain_entries_count(user)
  				if !remain_epp || remain_epp > 0
  					@matches_set << match
  				end
  			end
  		end
  		@matches_set_count = @matches_set.size
		end
	end
	
	def after_create_ok
		respond_to do |format|
			format.html do
				if @remain_epp
					flash[:notice] = "你已经成功提交了1个新#{ENTRY_CN}, 还可以提交#{@remain_epp - 1}个#{ENTRY_CN}!"
				else
					flash[:notice] = "你已经成功提交了1个新#{ENTRY_CN}!"
				end
				redirect_to item_first_link(@entry.match, true)
			end
			# format.xml  { render :xml => @entry, :status => :created, :location => @entry }
		end
	end
	
	def after_create_error
		respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你还没有选择要参加的#{MATCH_CN}!"
				
				load_matches_set
				
				info = "新#{ENTRY_CN} [#{name_for(@parent_type)}]"
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			# format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
		end
	end
	
	def after_destroy_ok
		respond_to do |format|
			format.html do
				entriable_type = type_for(@entriable)
				flash[:notice] = "你已经#{CANCLE_CN}了这#{unit_for(entriable_type)}#{name_for(entriable_type)}继续参赛!"
				redirect_to @entriable
			end
		end
	end
	
end
