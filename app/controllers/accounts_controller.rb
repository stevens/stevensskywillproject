class AccountsController < ApplicationController
	
	before_filter :protect
	before_filter :set_title
		
	def edit
		@user = @current_user
		
		if params[:id] == 'portrait'
			@new_portrait = @current_user.photos.build
		end	
	end
	
	def update	
    @user = @current_user

		if params[:id] == 'portrait'
			@new_portrait = @current_user.photos.build(params[:photo])
			@new_portrait.photoable_type = 'User'
			@new_portrait.photoable_id = @current_user.id
      if @new_portrait.save
				load_current_portrait
				if @current_portrait
					@current_portrait.destroy
				end
				after_update_ok
      else
				after_update_error
      end
		elsif params[:id] != 'nickname'
			if User.authenticate(User.find_by_id(session[:user_id]).email, params[:password])
			  @password_error = false
			  if @user.update_attributes(params[:user])
					after_update_ok
			  else
					after_update_error
			  end
			else
				@password_error = true
				after_update_error
		  end
		else
			if params[:user][:login]
				params[:user][:login] = str_squish(params[:user][:login], 0)
			end
		  if @user.update_attributes(params[:user])
				after_update_ok
		  else
				after_update_error
		  end
		end
	end
	
	def delete
		if params[:id] == 'portrait' && @current_portrait = user_portrait(@current_user)
			@current_portrait.destroy
			
			after_destroy_ok
		end
	end

	private
	
	def load_current_portrait
		@current_portrait = @current_user.photos.find(:first, 
																									:conditions => ["photoable_type = 'User' AND 
																																	 photoable_id = ? AND 
																																	 id <> ?", 
																																	 @current_user.id, 
																																	 @new_portrait.id])
	end

	def set_title
		if params[:id] == 'portrait' && !user_portrait(@current_user)
			info = "#{UPLOAD_CN}#{name_for(params[:id])}"
		else
			info = "#{CHANGE_CN}#{name_for(params[:id])}"
		end
		
		set_page_title(info)
		set_block_title(info)
	end
	
  def after_update_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{UPDATE_CN}了你的#{name_for(params[:id])}!"
			format.html { redirect_to :controller => 'settings', :action => 'account' }
			format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
  		if @password_error
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{PASSWORD_CN}有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			else
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{name_for(params[:id])}有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			end
			format.html { render :action => "edit", :id => params[:id] }
			format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
		end
		clear_notice
  end
  
  def after_destroy_ok
		respond_to do |format|
			flash[:notice] = "你已经成功#{DELETE_CN}了#{PORTRAIT_CN}!"
		  format.html { redirect_to :controller => 'settings', :action => 'account'}
		  format.xml  { head :ok }
		end
  end

end
