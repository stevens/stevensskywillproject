class ElectAwardsController < ApplicationController

#  before_filter :admin_protect

  def show
    load_awardin
    @item_for_bar = @awardin
    
    load_award_categories
    load_award

    if @award_category.award_type == '11' && @award.status == '12'
      load_winners
      if @award_category.elect_mode == '10'
        @show_ballot_info = true
        load_ballot_result
        load_ballot_groups

        show_sidebar
      end
    end

    awardin_type = type_for(@awardin)
    awardin_name = name_for(awardin_type)
    awardin_title = item_title(@awardin)
    @award_category_title = item_title(@award_category)
		@award_title = item_title(@award)

		info = "#{AWARD_CN}详情 - #{@award_category_title} - #{@award_title}"
		set_page_title(info)
		set_block_title(info)
		@meta_description = "这是#{awardin_name}(#{awardin_title})的#{AWARD_CN}(#{@award_category_title}-#{@award_title})详情信息。"
		set_meta_keywords
		@meta_keywords = [ awardin_name, awardin_title, @award_category_title, @award_title ] + @meta_keywords

    respond_to do |format|
      format.html
    end
  end

  private

  def set_meta_keywords
		@meta_keywords = [ '奖项' ]
	end

  def load_awardin
    if %w[ Election ].include?(@parent_type)
      @awardin = @parent_obj
    end
  end

  def load_award_categories
    award = ElectAward.find_by_id(@self_id)
    @award_categories = @awardin.great_awards
    for award_category in @award_categories
      if award.parent && award.parent == award_category
        @award_category = award_category
        break
      end
    end
  end

  def load_award
    @award = @award_category.childs.find_by_id(@self_id)
  end

  def load_winners
    @winners = @award.winners
    @winner = @winners[0]
  end

  def load_ballot_result
    @ballot_result = @award.ballot_results.find(:first)
  end

  def load_ballot_groups
    @ballot_groups = @award.ballots.group_by { |ballot| (ballot.ballot_content) }.sort { |a, b| b[1].size <=> a[1].size }
  end

end
