module ContactsHelper

	def filtered_contacts(user = nil, filter = nil, limit = nil, order = 'created_at DESC')
 		if @user && !filter
 			filter = 'accepted'
 		end
		contact_status_cond = codes_for(code_conditions('contact_status', nil, nil, filter), 1)[0].code if filter
 		contact_conditions = contact_conditions('1', contact_status_cond)
 		contacts_for(user, contact_conditions, limit, order)
	end
	
	def contacts_for(user, conditions = contact_conditions('1', '3'), limit = nil, order = 'contact_type, accepted_at DESC, created_at DESC')
		user.contacts.find(:all, :limit => limit, :order => order, 
											 :conditions => conditions)
	end
  
  def contact_conditions(contact_type = nil, status = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["contacts.contactor_id IS NOT NULL", 
  								"contacts.contactor_id <> ''", 
  								"contacts.contact_type IS NOT NULL", 
  								"contacts.contact_type <> ''"]
  	conditions << "contacts.contact_type = '#{contact_type}'" if contact_type
  	conditions << "contacts.status = #{status}" if status
  	conditions << "contacts.accepted_at IS NOT NULL" if status == '3'
		conditions << "contacts.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "contacts.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end
  
  def contactors_for(contacts)
  	contactors = []
  	for contact in contacts
  		contactors << contact.contactor
  	end
  	contactors
  end

end
