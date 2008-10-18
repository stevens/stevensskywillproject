class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
	before_filter :clear_location_unless_logged_in
	before_filter :set_system_notice, :only => [:overview]

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
    @user.login = str_squish(@user.login)
		
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
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :controller => 'mine', :action => 'overview' }
      else
		  	@reviewable_type = 'Recipe'
		  	
		  	load_user_recipes(@user)
		  	load_user_reviews(@user)
			 	load_user_tags(@user)
			 	
			 	info = "#{username_prefix(@user)}#{SITE_NAME_CN}"
				set_page_title(info)
				
				show_sidebar
				
      	format.html # overview.html.erb
      end
    end
  end
	
	private

	def load_user_recipes(user = nil)
		@recipes_set = recipes_for(user)
		@recipes_set_count = @recipes_set.size
	end
	
	def load_user_reviews(user = nil)
  	review_conditions = review_conditions(@reviewable_type)
  	if @reviewable_type == 'Recipe'
	 		reviewable_conditions = recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user))
	 	end
 		@reviews_set = reviews_for(user, @reviewable_type, review_conditions, reviewable_conditions)
  	@reviews_set_count = @reviews_set.size
	end
	
	def load_user_tags(user = nil)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
	  @tags_set_count = @tags_set.size
	end
	
  def after_create_ok
  	self.current_user = @user
  	session[:user_id] = nil
  	respond_to do |format|
			format.html do
	      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!<br />
	      								 如果偶尔不能收到#{EMAIL_CN}, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系......"				
				redirect_to root_path
			end
			format.xml  { render :xml => @user, :status => :created, :location => @user }
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do 
	      flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{ACCOUNT_CN}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				info = "加入#{SITE_NAME_CN}"	
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
		end
  end
  
end
