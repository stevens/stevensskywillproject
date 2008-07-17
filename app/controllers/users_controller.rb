class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
	
	before_filter :set_title
	
  def index
  	
  end
  
  def new
  	
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}) 查收#{SITE_NAME_CN}#{ACCOUNT_CN}#{SIGN_UP_CN}确认#{EMAIL_CN}!"
      session[:user_id] = nil
      redirect_to :controller => "site"
      # redirect_back_or_default('/')
    else
      flash[:notice] = "你输入的#{SIGN_UP_CN}信息有#{ERROR_CN}, 请重新输入!"
      render :action => 'new'
      flash[:notice] = nil	
    end
  end

  def activate
    activation_code = params[:id]
    self.current_user = activation_code.blank? ? false : User.find_by_activation_code(activation_code)
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "#{@current_user.login}, 恭喜你加入#{SITE_NAME_CN}!"
    end
    redirect_back_or_default('/')
  end

	private
	
	def set_title
	 	info = "加入#{SITE_NAME_CN}"
		set_page_title(info)
		set_block_title(info)
	end

end
