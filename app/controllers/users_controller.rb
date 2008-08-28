class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
	
  def index
  	
  end
  
  def show
  
  end
  
  def new
  	@user = User.new

	 	info = "加入#{SITE_NAME_CN}"
		
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    
    # @user.save
    # if @user.errors.empty?
    #   self.current_user = @user
    #   flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!"
    #   session[:user_id] = nil
		# 	redirect_back_or_default('/')
    # else
    #   flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{ACCOUNT_CN}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
    #   render :action => 'new'
    #   flash[:notice] = nil	
    # end
		
		if @user.save
			after_create_ok
		else
			after_create_error
		end
  end

	def edit
		@user = @current_user

	 	info = "#{CHANGE_CN}#{NICKNAME_CN}"
		
		set_page_title(info)
		set_block_title(info)
	end

	def update
		@user = @current_user
		
	  if @user.update_attributes(params[:user])
			after_update_ok
	  else
			after_update_error
	  end
	end
	
	def destroy
	
	end
	
	def enable
	
	end
	
  def activate
    activation_code = params[:id]
    self.current_user = activation_code.blank? ? false : User.find_by_activation_code(activation_code)
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "#{@current_user.login}, 恭喜你加入#{SITE_NAME_CN}, 现在开始做一个蜂狂的厨师吧!"
    end
    redirect_back_or_default('/')
  end
	
	private
	
  def after_create_ok
  	self.current_user = @user
  	session[:user_id] = nil
  	respond_to do |format|
      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!"
			format.html { redirect_to root_url }
			format.xml  { render :xml => @user, :status => :created, :location => @user }
		end
  end
  
  def after_create_error
  	respond_to do |format|
      flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{ACCOUNT_CN}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "new" }
			format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
			 		
			info = "加入#{SITE_NAME_CN}"
			 		
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
  
  def after_update_ok
  	respond_to do |format|
			flash[:notice] = "你已经成功#{CHANGE_CN}了你的#{NICKNAME_CN}!"
			format.html { redirect_to :controller => 'settings', :action => 'account' }
			format.xml  { head :ok }
		end
  end
  
  def after_update_error
  	respond_to do |format|
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{NICKNAME_CN}有#{ERROR_CN}, 请重新#{INPUT_CN}!"
			format.html { render :action => "edit" }
			format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
			
		 	info = "#{CHANGE_CN}#{NICKNAME_CN}"
			
			set_page_title(info)
			set_block_title(info)
		end
		clear_notice
  end
end
