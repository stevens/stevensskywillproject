module ElectWinnersHelper

  def elect_winner_groups(winnerin)
    item_grands = winnerin.awards

    item_groups = []
    i = 0
    for item_grand in item_grands
      item_groups << { :item_grand => item_grand, :item_parents => [] }
      j = 0
      for item_parent in item_grand.childs
        item_groups[i][:item_parents] << { :item_parent => item_parent, :items => [] }
        for winner in item_parent.winners.find(:all, :order => 'winnerable_id')
          item_groups[i][:item_parents][j][:items] << winner.winnerable
        end
        j += 1
      end
      i += 1
    end
    item_groups
  end
    
end
