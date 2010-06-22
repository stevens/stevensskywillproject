class ElectionsController < ApplicationController

  include ApplicationHelper

  before_filter :preload_models
#  before_filter :admin_protect
  before_filter :protect, :except => [:index, :show, :overview, :profile]

  def index

  end

  def show
    load_election
    @item_for_bar = @election

		# show_sidebar

		election_title = item_title(@election)
		election_username = user_username(@election.user, true, true)
		election_link_url = item_first_link(@election)

		info = "#{ELECTION_CN}详情 - #{election_title}"
		set_page_title(info)
		set_block_title(info)
		@meta_description = "这是#{election_title}的#{ELECTION_CN}详情信息, 来自#{election_username}."
		set_meta_keywords
		@meta_keywords = [ election_title, election_username, election_link_url ] + @meta_keywords
		@meta_keywords << @election.tag_list if !@election.tag_list.blank?

    respond_to do |format|
      format.html
    end
  end

  def new

  end

  def edit

  end

  def create

  end

  def update

  end

  def destroy

  end

  def profile
    load_election
    @item_for_bar = @election

#    if @current_user && @current_user.is_role_of?('admin')
#      load_nomination_groups
#      load_winner_groups
#      @show_nominations = true
#      @show_winners = true
#    else
      if @election.is_status_of?('todo') || @election.is_status_of?('doing') || @election.is_status_of?('doing_nomination') || @election.is_status_of?('doing_voting') || @election.is_status_of?('doing_gala_todo')
        load_nomination_groups
        @show_nominations = true
        @nomination_published_at = '今晚21点'
      elsif @election.is_status_of?('doing_gala_doing') || @election.is_status_of?('doing_gala_done') || @election.is_status_of?('done')
        load_winner_groups
        @show_winners = true
        @winner_published_at = '今天晚上'
      end
#    end

    load_partners
    load_judge_users

    load_notifications if @current_user

#    @award_groups = []
#    award_categories = @election.awards
#    i = 0
#    for award_category in award_categories
#      @award_groups[i] = []
#      @award_groups[i] << award_category
#      @award_groups[i] << award_category.childs
#      i += 1
#    end

  	show_sidebar

		election_title = item_title(@election)
		election_username = user_username(@election.user, true, true)
		election_link_url = item_first_link(@election, true)

		info = "#{ELECTION_CN} - #{election_title}"
		set_page_title(info)
		@meta_description = "这是#{election_title}的#{ELECTION_CN}主页, 来自#{election_username}."
		set_meta_keywords
		@meta_keywords = [ election_title, election_username, election_link_url ] + @meta_keywords
		@meta_keywords << @election.tag_list if !@election.tag_list.blank?

    respond_to do |format|
  		format.html do
  			log_count(@election)
  		end
    end
  end

  def overview

  end

  private

  def preload_models()
    Nomination
    ElectWinner
    ElectAward
    Recipe
    User
  end

  def set_meta_keywords
		@meta_keywords = [ '评选', '评选活动', '美食评选', '网络评选', '奖项', '投票', '提名', '评审', '颁奖', '获奖' ]
	end

  def load_election(user = nil)
  	if user
			@election = user.elections.find(@self_id)
		else
			@election = Election.find(@self_id)
		end
  end

  def load_nomination_groups
    nomination_groups_cache_id = "election_#{@election.id}_nominations_item_groups"
    begin
      @nomination_groups = CACHE.get(nomination_groups_cache_id)
    rescue Memcached::NotFound
      @nomination_groups = nomination_groups(@election)
      CACHE.set(nomination_groups_cache_id, @nomination_groups)
    end
  end

  def load_winner_groups
    winner_groups_cache_id = "election_#{@election.id}_elect_winners_item_groups"
    begin
      @winner_groups = CACHE.get(winner_groups_cache_id)
    rescue Memcached::NotFound
      @winner_groups = elect_winner_groups(@election)
      CACHE.set(winner_groups_cache_id, @winner_groups)
    end
  end

  def load_partners
    @partners = []
    for partnership_category in @election.partnership_categories
      for partnership in partnership_category.partnerships
        @partners << partnership.partyb
      end
    end
  end

  def load_judge_users
    @judge_users = []
    for judge in @election.judges.find(:all, :limit => 36, :order => 'RAND()')
      @judge_users << judge.user
    end
  end

  def load_notifications(user = @current_user)
    unless @election.is_status_of?('todo') || @election.is_status_of?('close_any')
      @notifications = []
      if (@election.is_status_of?('doing_gala_done') || @election.is_status_of?('done')) && (winners = @election.winners.find(:all, :conditions => { :user_id => user.id })) && (winners_count = winners.size) > 0
        @notifications << [ "恭喜你获得#{winners_count}个#{AWARD_CN}", "/elections/#{@election.id}/elect_winners" ]
      end
      if !(@election.is_status_of?('doing') || @election.is_status_of?('doing_nomination_todo')) && (nominations = @election.nominations.find(:all, :conditions => { :user_id => user.id })) && (nominations_count = nominations.size) > 0
        @notifications << [ "恭喜你获得#{nominations_count}#{UNIT_NOMINATION_CN}#{NOMINATION_CN}", "/elections/#{@election.id}/nominations" ]
      end
      if (@election.is_status_of?('doing_voting_doing') || @election.is_status_of?('doing_voting_done') || @election.is_status_of?('doing_gala') || @election.is_status_of?('done')) && (ballots = @election.ballots.find(:all, :conditions => { :user_id => user.id })) && (ballots_count = ballots.size) >= 0
        if @election.is_status_of?('doing_voting_doing')
          remaining_time = (Time.local(2010, 4, 16, 0, 0, 0) - Time.now).to_i
          if second_to_day(remaining_time) >= 1
            remaining_time_display = time_display(remaining_time, 'd')
          elsif second_to_hms(remaining_time)[:h] >= 1
            remaining_time_display = time_display(remaining_time, 'h')
          elsif second_to_hms(remaining_time)[:m] >= 1
            remaining_time_display = time_display(remaining_time, 'hm')
          elsif second_to_hms(remaining_time)[:s] >= 1
            remaining_time_display = time_display(remaining_time, 'hms')
          end
          @notifications << [ "#{VOTE_CN}将于4月16日凌晨零点结束，还剩#{remaining_time_display}", "/elections/#{@election.id}/nominations" ]
        end
        @notifications << [ "你已为#{ballots_count}个#{AWARD_CN}#{VOTE_CN}，剩余#{@election.vote_awards_count - ballots_count}个#{AWARD_CN}", "/elections/#{@election.id}/nominations" ]
      end
      if @election.judges.find(:first, :conditions => { :user_id => user.id })
        @notifications << [ "你是这#{UNIT_ELECTION_CN}#{ELECTION_CN}的特邀#{JUDGE_CN}", "/elections/#{@election.id}/judges" ]
      end
    end
  end

end
