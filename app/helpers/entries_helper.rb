module EntriesHelper

	def filtered_entries(match, user = nil, filter = nil, limit = nil, order = 'created_at DESC')
  	if user && !filter.blank?
  		case filter
  		when 'submitted'
  			entries_set = match.entries.find(:all, :conditions => { :user_id => user.id })
  		when 'voted'
  			votes_set = match.votes.find(:all, :conditions => { :user_id => user.id })
  			entries_set = voteables_for(votes_set)
  		end
  	else
  		entries_set = match.entries.find(:all)
  	end
  	entries_set
	end

  def entriables_for(entries)
  	entriables = []
  	for entry in entries
  		entriables << entry.entriable if entry.entriable.entriable?
  	end
  	entriables
  end
  
  def entried_matches(entries)
  	matches = []
  	for entry in entries
  		matches << entry.match if (entry.match && entry.match.accessible?)
  	end
  	matches
  end
end
