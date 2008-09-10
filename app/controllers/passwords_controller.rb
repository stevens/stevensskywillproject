class PasswordsController < ApplicationController
	
	before_filter :set_title
	
	def new

	end

	def create
		# if request.post?
		# 	params[:email] = text_useful(params[:email])
			if params[:email] =~ /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i	
		    if @user = User.find_for_forget(params[:email])
					@user.forgot_password
					if @user.update_attribute(:password_reset_code, @user.password_reset_code)
			    	flash[:notice] = "请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{PASSWORD_CN}#{RESET_CN}#{EMAIL_CN}!"
			    	redirect_to login_url
		    	else
	    			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{EMAIL_ADDRESS_CN}有#{ERROR_CN}, 请重新#{INPUT_CN}!"
	    			render :action => 'new'
   					clear_notice
		    	end
		    else
		    	flash[:notice] = "#{SORRY_CN}, 这个#{EMAIL_ADDRESS_CN}还没有#{SIGN_UP_CN}#{ACCOUNT_CN}!"
		    	render :action => 'new'
    			clear_notice
		    end
			elsif params[:email]
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{EMAIL_ADDRESS_CN}格式不正确, 请重新#{INPUT_CN}!"
				render :action => 'new'
				clear_notice
		# 	else
		# 		flash[:notice] = "#{SORRY_CN}, 你还没有#{INPUT_CN}#{EMAIL_ADDRESS_CN}!"
		# 		redirect_to forgot_password_url
			end
		# else
		# 	redirect_to forgot_password_url
		# end
	end
	
	def edit
		if params[:id]
			@user = User.find_by_password_reset_code(params[:id])
			unless @user
				after_password_reset_code_error
			end
		else
			after_password_reset_code_nil
		end
	end
	
	def update
		if params[:id]
			@user = User.find_by_password_reset_code(params[:id])
			if @user
				@user.reset_password
				
				if @user.update_attributes(params[:user])
					flash[:notice] = "你已经重新设置了#{ACCOUNT_CN}#{PASSWORD_CN}!"
					redirect_to login_url
			  else
					flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{PASSWORD_CN}有#{ERROR_CN}, 请重新#{INPUT_CN}!"
					render :action => "edit", :id => params[:id]
					clear_notice
			  end
			else
				after_password_reset_code_error
			end
		else
			after_password_reset_code_nil
		end
	end

	private
	
	def set_title
		info = "#{RESET_CN}#{PASSWORD_CN}"
		
		set_page_title(info)
		set_block_title(info)
	end
	
	def after_password_reset_code_nil
		flash[:notice] = "#{SORRY_CN}, 没有#{PASSWORD_CN}#{RESET_CN}的校验码, 请查看#{PASSWORD_CN}#{RESET_CN}#{EMAIL_CN}!"
		redirect_to login_url
	end
	
	def after_password_reset_code_error
		flash[:notice] = "#{SORRY_CN}, #{PASSWORD_CN}#{RESET_CN}的校验码不正确, 请查看#{PASSWORD_CN}#{RESET_CN}#{EMAIL_CN}!"
		redirect_to login_url
	end
end
