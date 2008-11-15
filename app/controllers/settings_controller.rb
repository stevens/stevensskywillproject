class SettingsController < ApplicationController
	
	before_filter :protect
	
	def account
	 	@account = @current_user
	 	@current_portrait = user_portrait(@current_user)
	 	
		if profile = @current_user.profile
			@profile = profile
		else
			@profile = Profile.new
		end
	 	
	 	info = "#{ACCOUNT_CN}#{SETTING_CN}"
	 	
		set_page_title(info)
		set_block_title(info)
	end
	
	def privacy
	
	end
	
end
