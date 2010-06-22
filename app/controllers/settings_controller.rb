class SettingsController < ApplicationController
	
	before_filter :protect
	
	def account
	 	@account = @current_user
	 	@current_portrait = user_portrait(@current_user)
	 	
	 	info = "#{ACCOUNT_CN}#{SETTING_CN}"
	 	
		set_page_title(info)
		set_block_title(info)
	end

  def profile
    respond_to do |format|
      format.html do
        if profile = @current_user.profile
          redirect_to "/profiles/#{profile.id}/edit"
        else
          redirect_to "/profiles/new"
        end
      end
    end
  end
	
	def privacy
	
	end
	
end
