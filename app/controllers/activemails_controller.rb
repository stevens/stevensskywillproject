class ActivemailsController < ApplicationController
  	before_filter :set_pagetitle
	
	def new

	end
        
        def create
		if params[:email] =~ /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i	
			@user = User.find_by_email(params[:email])
			if @user && @user.activated_at
				flash[:notice] = "你好，你这个注册#{ACCOUNT_CN}已经处于激活状态，无需再激活，直接登录即可!<br /><br />
													 如果登录有问题, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系......"
				redirect_to login_url
			elsif @user
                                @user.resend
				flash[:notice] = "你好, #{ACTIVATE_CN}#{EMAIL_CN}已经发送到你的注册#{MAILBOX_CN}，请查收！<br /><br />
													 如果遇到问题, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系......"
				redirect_to login_url		
                        else
                                flash[:notice] = "#{SORRY_CN}, 这个#{EMAIL_ADDRESS_CN}还没有#{SIGN_UP_CN}#{ACCOUNT_CN}!"
				render :action => 'new'
				clear_notice
			end
		elsif params[:email]
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{EMAIL_ADDRESS_CN}格式不正确, 请重新#{INPUT_CN}!"
			render :action => 'new'
			clear_notice
		end
	end
        private
	
	def set_pagetitle
		info = "#{RESEND_CN}#{ACTIVATE_CN}#{EMAIL_CN}"
		set_page_title(info)
		set_block_title(info)
	end
end
