class VotesController < ApplicationController
	
	before_filter :protect
	
	def new
		votein_id_sym = id_for(params[:votein_type].camelize).to_sym
		redirect_to votein_id_sym => params[:votein_id], :controller => controller_name(@parent_type), :action => 'index', :filter => params[:filter]
	end
	
	def create
		@vote = @parent_obj.votes.build
		@vote.user_id = @current_user.id
		@vote.votes = 1
		@vote.votein_type = params[:votein_type].camelize
		@vote.votein_id = params[:votein_id]
		
		load_votein
		current = Time.now
		if @votein.doing?(current) && (@votein.vote_time_status(current)[1] == 'doing')
			unless @votein.find_vote(@current_user, @parent_obj)
				@remain_epv = @votein.voter_remain_entries_count(@current_user)
				if !@remain_epv || @remain_epv > 0
					ActiveRecord::Base.transaction do
						@vote.save
						load_voteable
						voteable_total_votes = @voteable.total_votes + 1
						voteable_votes_count = @voteable.votes_count + 1
						if @voteable.update_attributes({ :total_votes => voteable_total_votes, :votes_count => voteable_votes_count })
							# @notice = "你还可以给#{@remain_epv - 1}#{unit_for('Entry')}#{ENTRY_CN}#{VOTE_CN}!"
							after_save_ok
						end
					end
				else
					@notice = "#{SORRY_CN}, 你最多只能#{VOTE_CN}给#{@votein.entries_per_voter}#{unit_for('Entry')}#{ENTRY_CN}!"
					after_save_error
				end
			end
		else
			@notice = "#{SORRY_CN}, 这#{unit_for(@vote.votein_type)}#{name_for(@vote.votein_type)}的#{VOTE_CN}没有开始或者已经结束!"
			after_save_error
		end
	end
	
	def vote
		load_vote
		if @vote && (current_votes = @vote.votes)
			if current_votes > 0
				load_voteable
				load_votein
				votes_per_entry = @votein.votes_per_entry
				case params[:vote_type]
				when 'ic'
					unless votes_per_entry && current_votes >= votes_per_entry
						new_votes = current_votes + 1
						voteable_total_votes = @voteable.total_votes + 1
					end
				when 'dc'
					unless current_votes <= 1
						new_votes = current_votes - 1
						voteable_total_votes = @voteable.total_votes - 1
					end
				end
				ActiveRecord::Base.transaction do
					@vote.update_attribute(:votes, new_votes)
					if @voteable.update_attribute(:total_votes, voteable_total_votes)
						after_save_ok
					end
				end
			end
		end
	end
	
	def destroy
		load_vote
		load_voteable
		load_votein
		voteable_total_votes = @voteable.total_votes - @vote.votes
		voteable_votes_count = @voteable.votes_count - 1
		ActiveRecord::Base.transaction do
			@vote.destroy
			if @voteable.update_attributes({ :total_votes => voteable_total_votes, :votes_count => voteable_votes_count})
				@redirect = true if params[:filter] == 'voted'
				after_save_ok
			end
		end
		
	end
	
	private
	
	def load_vote
		@vote = @current_user.votes.find(@self_id)
	end
	
	def load_voteable
		@voteable = @vote.voteable
	end
	
	def load_votein
		@votein = @vote.votein
	end
	
	def after_save_ok
		respond_to do |format|
			format.js do 
				render :update do |page|
					page.hide "flash_wrapper"
					page.replace_html "#{type_for(@voteable).downcase}_#{@voteable.id}_vote_bar", 
														:partial => "/votes/vote_bar", 
							 							:locals => { :voteable => @voteable, 
							 													 :votein => @votein, 
							 													 :show_vote_todo => true }
					page.visual_effect :highlight, "#{type_for(@voteable).downcase}_#{@voteable.id}_vote_data", :duration => 3
					if @redirect
						votein_id_sym = item_id(@votein).to_sym
						page.redirect_to votein_id_sym => @votein.id, :controller => controller_name(type_for(@voteable)), :action => 'index', :filter => 'voted'
					end
				end
			end
		end
	end
	
	def after_save_error
		respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "flash_wrapper", 
														:partial => "/layouts/flash",
											 			:locals => { :notice => @notice }
					page.show "flash_wrapper"
				end
			end
		end
	end
	
end
