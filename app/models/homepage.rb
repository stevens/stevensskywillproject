class Homepage < ActiveRecord::Base

	def self.find_for_sitemap
		find(:all, :select => 'content, updated_at',
				 :order => 'updated_at DESC',
				 :limit => 50000)
	end

end
