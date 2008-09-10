class AccountsController < ApplicationController
	
	before_filter :protect
	before_filter :set_title
		
	def edit
		@user = @current_user
		@current_nickname = User.find_by_id(@current_user.id).login
	end
	
	def update	
    @user = @current_user

		if params[:id] != 'nickname'
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
		  if @user.update_attributes(params[:user])
				after_update_ok
		  else
				after_update_error
		  end
		end
	end

	private

	def set_title
		info = "#{CHANGE_CN}#{name_for(params[:id])}"
		
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

end
