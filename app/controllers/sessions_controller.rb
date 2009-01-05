# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :set_title
	
  def new
  	show_sidebar
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
      end
      @current_user.log_loggedin #此行为新增
      flash[:notice] = "#{@current_user.login}, 你已经#{LOGIN_CN}#{SITE_NAME_CN}, 希望你在这里玩得开心!"
      redirect_back_or_default('/')
    else
    	flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{EMAIL_ADDRESS_CN}和#{PASSWORD_CN}有#{ERROR_CN}, 请重新#{INPUT_CN}!<br /><br />
    									 <em>如果你已经用这个#{EMAIL_ADDRESS_CN}注册过, 请核实是否收到#{ACCOUNT_CN}激活#{EMAIL_CN}并激活了你的#{ACCOUNT_CN}?</em><br />
    									 <em>如果偶尔未能收到#{ACCOUNT_CN}激活#{EMAIL_CN}</em>, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系..."
      show_sidebar
      render :action => 'new'
      clear_notice
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "#{@current_user.login}, 你已经#{LOGOUT_CN}#{SITE_NAME_CN}, 期待你的再次到来!"
    redirect_back_or_default('/')
  end
  
  private
  
	def set_title
	 	info = "#{LOGIN_CN}#{SITE_NAME_CN}"
		set_page_title(info)
		set_block_title(info)
	end

end
