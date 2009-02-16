class WinnersController < ApplicationController 

  def index
    @match = @parent_obj
    load_winners

    respond_to do |format|
    	format.html do
		  	info = "获奖名单 #{itemname_suffix(@parent_obj)}"
				set_page_title(info)
				set_block_title(info)
    	end
    end
  end

  private

  def load_winners
    @winners_set = @match.winners.group_by { |winner| winner.award_id }.sort_by { |winners| @match.awards.find_by_id(winners[0]).level }
  end

  def load_awards
    @awards_set = @match.awards.find(:all, :order => 'level')
  end
end
