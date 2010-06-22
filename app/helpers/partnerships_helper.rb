module PartnershipsHelper

  def partnership_groups(partya)
    item_parents = partya.partnership_categories

    item_groups = []
    i = 0
    for item_parent in item_parents
      item_groups << { :item_parent => item_parent, :items => [] }
      for item in item_parent.partnerships
        item_groups[i][:items] << item.partyb
      end
      i += 1
    end
    item_groups
  end
    
end
