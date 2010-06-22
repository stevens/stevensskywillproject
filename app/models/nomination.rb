class Nomination < ActiveRecord::Base

	belongs_to :user
	belongs_to :nominateable, :polymorphic => true
  belongs_to :nominateby, :polymorphic => true
  belongs_to :nominatein, :polymorphic => true
  belongs_to :nominatefor, :polymorphic => true

  def duplicated?
    Nomination.find(:first, :conditions => { :user_id => self.user_id,
                                            :nominateby_type => self.nominateby_type, :nominateby_id => self.nominateby_id,
                                            :nominatein_type => self.nominatein_type, :nominatein_id => self.nominatein_id,
                                            :nominatefor_type => self.nominatefor_type, :nominatefor_id => self.nominatefor_id,
                                            :nominateable_type => self.nominateable_type, :nominateable_id => self.nominateable_id })
  end

end
