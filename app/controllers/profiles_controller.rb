class ProfilesController < ApplicationController

  def create
    @profile = Profile.new(params[:profile])
		@profile.user = @current_user
		@profile.blog = url_without_protocol(params[:profile][:blog])
		item_client_ip(@profile)
		
    respond_to do |format|
      if @profile.save
				format.html { redirect_to :controller => 'settings', :action => 'account' }
      else
				format.html { render '' }
      end
    end
  end

  def update
    @profile = Profile.find(params[:id])
		params[:profile][:blog] = url_without_protocol(params[:profile][:blog])
		
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
				format.html { redirect_to :controller => 'settings', :action => 'account' }
      else
        format.html { render '' }
      end
    end
  end

end
