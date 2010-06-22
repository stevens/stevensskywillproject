module NominationsHelper

  def nomination_groups(nominatein, options = {})
    if !options[:group_by].blank?
      case options[:group_by]
      when 'user'
        item_grands = nominatein.nominations.group_by { |nomination| (nomination.user) }.sort { |a, b| b[1].size <=> a[1].size }
        item_groups = []
        i = 0
        for item_grand in item_grands
          item_groups << { :item_grand => item_grand[0], :item_parents => [] }
          j = 0
          for item_parent in nominatein.vote_awards
            item_groups[i][:item_parents] << { :item_parent => item_parent, :items => [] }
            awards = item_parent.childs
            for nomination in item_grand[1]
              nominatefor = nomination.nominatefor
              if awards.include?(nominatefor)
                nominateable = nomination.nominateable
                item_groups[i][:item_parents][j][:items] << { :nominatefor => nominatefor, :nominateable => nominateable }
              end
            end
            item_groups[i][:item_parents][j][:items].sort! { |a, b| a[:nominatefor].sequence <=> b[:nominatefor].sequence }
            j += 1
          end
          i += 1
        end
      end
    else
      item_grands = nominatein.vote_awards
      item_groups = []
      i = 0
      for item_grand in item_grands
        item_groups << { :item_grand => item_grand, :item_parents => [] }
        j = 0
        for item_parent in item_grand.childs
          item_groups[i][:item_parents] << { :item_parent => item_parent, :items => [] }
          for nomination in item_parent.nominations.find(:all, :order => 'nominateable_id')
            item_groups[i][:item_parents][j][:items] << nomination.nominateable
          end
          j += 1
        end
        i += 1
      end
    end
    item_groups
  end
    
end
