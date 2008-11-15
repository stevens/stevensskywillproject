class Contact < ActiveRecord::Base

	belongs_to :user
	belongs_to :contactor, :class_name => "User", :foreign_key => "contactor_id"
	
	validates_presence_of :user_id, :contactor_id
	
	def self.friendship_exists?(user, contactor)
		find_by_user_id_and_contactor_id_and_contact_type(user, contactor, '1') ? true : false
	end
	
	def self.friendship_request(user, contactor)
		unless user == contactor || Contact.friendship_exists?(user, contactor)
			transaction do
				create(:user => user, :contactor => contactor, :contact_type => '1', :status => '2')
				create(:user => contactor, :contactor => user, :contact_type => '1', :status => '1')
			end
		end
	end
	
	def self.friendship_accept(user, contactor)
		if Contact.friendship_exists?(user, contactor)
			transaction do
				accepted_at = Time.now
				accept_one_side(user, contactor, accepted_at)
				accept_one_side(contactor, user, accepted_at)
			end
		end
	end
	
	def self.friendship_breakup(user, contactor)
		if Contact.friendship_exists?(user, contactor)
			transaction do
				destroy(find_by_user_id_and_contactor_id(user, contactor))
				destroy(find_by_user_id_and_contactor_id(contactor, user))
			end
		end
	end
	
	private

	def self.accept_one_side(user, contactor, accepted_at)
		request = find_by_user_id_and_contactor_id(user, contactor)
		request.status = '3'
		request.accepted_at = accepted_at
		request.save!
	end
	
end
