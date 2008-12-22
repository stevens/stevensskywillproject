class ContactObserver < ActiveRecord::Observer
  def after_create(contact)
		UserMailer.deliver_friendship_request(contact) if contact.contact_type == '1' && contact.status == '1'
  end
  
end
