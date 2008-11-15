class ProfilesController < ApplicationController

  def create
    @profile = Profile.new(params[:profile])
		@profile.user = @current_user
		@profile.blog = str_squish(params[:profile][:blog], 0).gsub("http://", '')
		
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
		params[:profile][:blog] = str_squish(params[:profile][:blog], 0).gsub("http://", '')
		
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
				format.html { redirect_to :controller => 'settings', :action => 'account' }
      else
        format.html { render '' }
      end
    end
  end

end
