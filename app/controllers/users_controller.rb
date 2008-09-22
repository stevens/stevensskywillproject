class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
	before_filter :clear_location_unless_logged_in

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

    # else

    # end
		
		if @user.save
			after_create_ok
		else
			after_create_error
		end
  end

	def edit

	end

	def update

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
  
  def overview
    if !(@user && @user == @current_user)
    	@integrality = 'more_required'
    end
  
  	load_user_recipes(@user)
  	@recipes = @recipes_set[0..MATRIX_ITEMS_COUNT_PER_PAGE_S - 1]
  	
  	load_user_reviews(@user)
  	@reviews = @reviews_set[0..LIST_ITEMS_COUNT_PER_PAGE_S - 1]
	 	
	 	info = "#{user_username(@user)}的#{SITE_NAME_CN}"
		set_page_title(info)
		
    respond_to do |format|
      if @user && @user == @current_user
      	@show_todo = true
      	format.html { redirect_to :controller => 'mine', :action => 'overview' }
      else
      	format.html # overview.html.erb
      end
    end
  end
	
	private

	def load_user_recipes(user)
		@recipes_set = recipes_for(user, @integrality, nil, nil, 'created_at DESC')
		@recipes_set_count = @recipes_set.size
	end
	
	def load_user_reviews(user)
		@reviews_set = reviews_for(user, @reviewable_type, nil, nil, nil, 'created_at DESC')
		@reviews_set_count = @reviews_set.size
	end
	
  def after_create_ok
  	self.current_user = @user
  	session[:user_id] = nil
  	respond_to do |format|
      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!<br />
      								 如果偶尔有时不能收到#{EMAIL_CN}, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系, 谢谢!"
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
  
end
