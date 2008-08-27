class SettingsController < ApplicationController
	
	before_filter :protect
	
	def account
	 	@account = @current_user
	 	
	 	info = "#{ACCOUNT_CN}#{SETTING_CN}"
	 	
		set_page_title(info)
		set_block_title(info)
	end
	
	def privacy
	
	end
	
end
