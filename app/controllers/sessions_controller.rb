# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :set_title

  def new
  	
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "#{@current_user.login}, 你已经成功#{LOGIN_CN}#{SITE_NAME_CN}!"
      redirect_back_or_default('/')
    else
    	flash[:notice] = "你输入的#{ACCOUNT_ID_CN}和#{PASSWORD_CN}有#{ERROR_CN}, 请重新输入!"
      render :action => 'new'
      flash[:notice] = nil
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "#{@current_user.login}, 你已经#{LOGOUT_CN}#{SITE_NAME_CN}!"
    redirect_back_or_default('/')
  end
  
  private
  
	def set_title
	 	info = "#{LOGIN_CN}#{SITE_NAME_CN}"
		set_page_title(info)
		set_block_title(info)
	end

end
