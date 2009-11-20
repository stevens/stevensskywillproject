class ProfilesController < ApplicationController

  def create
    @profile = Profile.new(params[:profile])
		@profile.user = @current_user
		@profile.blog = url_without_protocol(params[:profile][:blog])
    @profile.taobao = str_squish(params[:profile][:taobao], 0, false)
		item_client_ip(@profile)
		
    respond_to do |format|
      if @profile.save
        flash[:notice] = "你已经成功设置了帐户信息!"
				format.html { redirect_to :controller => 'settings', :action => 'account' }
      else
        format.html { redirect_to :controller => 'settings', :action => 'account' }
#        format.html { render '' }
      end
    end
  end

  def update
    @profile = Profile.find(params[:id])
		params[:profile][:blog] = url_without_protocol(params[:profile][:blog])
    params[:profile][:taobao] = str_squish(params[:profile][:taobao], 0, false)
		
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = "你已经成功设置了帐户信息!"
				format.html { redirect_to :controller => 'settings', :action => 'account' }
      else
        format.html { redirect_to :controller => 'settings', :action => 'account' }
#        format.html { render '' }
      end
    end
  end

end
