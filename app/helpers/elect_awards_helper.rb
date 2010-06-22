module ElectAwardsHelper

  def vote_awards_count(awardin)
    count = 0
    for award_category in awardin.vote_awards
      for award in award_category.childs
        count += 1
      end
    end
    count
  end
  
end
