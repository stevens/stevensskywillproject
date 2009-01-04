class MatchActor < ActiveRecord::Base

	belongs_to :user
	belongs_to :match
	
	def self.find_an_actor(match, user, role)
		if match && user && role
			find_by_match_id_and_user_id_and_roles(match.id, user.id, role)
		end
	end
	
end
