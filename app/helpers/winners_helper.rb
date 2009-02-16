module WinnersHelper
  def awardable_type_winners(match, awardable_type, limit = nil, order = 'RAND()')
    match.winners.find(:all, :limit => limit, :order => order,
                      :joins => "JOIN awards ON winners.award_id = awards.id",
                      :conditions => "awards.awardable_type = '#{awardable_type}'")
  end

  def winnerables_for(winners)
  	winnerables = []
  	for winner in winners
  		winnerables << winner.winnerable
  	end
  	winnerables
  end

end
