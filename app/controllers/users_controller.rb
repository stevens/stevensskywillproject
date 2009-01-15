class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
	before_filter :clear_location_unless_logged_in
	before_filter :load_category, :only => [:index, :overview]

  def index
  	load_users_set
  	
  	case params[:category]
  	when 'brain'
  		title = "#{BRAIN_CN}团"
  	else
  		title = PEOPLE_CN
  	end
  	
  	# info = "#{title} (#{@users_set_count})"
  	info = "#{title}"
		set_page_title(info)
		set_block_title(info)
  	
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
      # format.xml  { render :xml => @user }
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
  
  def lost_activation
  	info = "重发激活#{EMAIL_CN}"
		set_page_title(info)
		set_block_title(info)
  end
  
  def resend_activation
		info = "重发激活#{EMAIL_CN}"
		set_page_title(info)
		set_block_title(info)
		
		if params[:email] =~ /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i	
			@user = User.find_by_email(params[:email])
			if @user && !@user.activated_at
				UserMailer.deliver_signup_notification(@user)
	      flash[:notice] = "#{@user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收<em>#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}</em>!<br /><br/>
	      								 <em>如果偶尔未能收到#{ACCOUNT_CN}激活#{EMAIL_CN}</em>, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系..."				
				redirect_to login_url
			else
				flash[:notice] = "#{SORRY_CN}, 这个#{EMAIL_ADDRESS_CN}还没有#{SIGN_UP_CN}#{ACCOUNT_CN} 或者 用这个#{EMAIL_ADDRESS_CN}#{SIGN_UP_CN}的#{ACCOUNT_CN}已经激活!"
				render :action => 'lost_activation'
				clear_notice			    	
			end
		elsif params[:email]
			flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{EMAIL_ADDRESS_CN}格式不正确, 请重新#{INPUT_CN}!"
			render :action => 'lost_activation'
			clear_notice
		end  	
  end
  
  def overview
	  load_users_set
	  load_brains_set
	  load_random_users
	  
  	# @highlighted_user = 
  	# @highest_rated_users = 
  	# @random_users = random_items(@users_set, 12)
	  
	  info = "#{PEOPLE_CN}"
		set_page_title(info)
		
		show_sidebar
  end
  
  def profile
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :controller => 'mine', :action => 'profile' }
      elsif @user
		  	load_user_recipes(@user)
		  	# classify_recipes
		  	load_user_reviews(@user)
		  	load_user_favorites(@user)
		  	# classify_favorite_statuses
			 	load_user_tags(@user)
			 	load_user_contactors(@user)
			 	
			 	log_count(@user)
			 	
			 	info = "#{username_prefix(@user)}#{MAIN_PAGE_CN}"
				set_page_title(info)
				
				show_sidebar
				
      	format.html # profile.html.erb
      end
    end
  end
	
	private
	
	def load_category
		if role_name = params[:category]
			@role_code = user_role_code(role_name)
		end
	end
	
  def load_users_set
 		@users_set = users_for(user_conditions(@role_code))
  	@users_set_count = @users_set.size
  end
  
  def load_brains_set
  	@brains_set = users_for(user_conditions(user_role_code('brain')), 4, 'RAND()')
  	@brains_set_count = @brains_set.size
  end
  
  def load_random_users
  	@random_users = users_for(user_conditions, 12, 'RAND()')
  end

	def load_user_recipes(user = nil)
		@recipes_set = recipes_for(user)
		@recipes_set_count = @recipes_set.size
	end
	
	def load_user_reviews(user = nil)
  	reviewable_type = @reviewable_type || 'Recipe'
 		@reviews_set = filtered_reviews(user, reviewable_type)
  	@reviews_set_count = @reviews_set.size
	end
	
	def load_user_favorites(user = nil)
  	favorable_type = @favorable_type || 'Recipe'
		@favorites_set = filtered_favorites(user, favorable_type)
  	@favorites_set_count = @favorites_set.size
	end
	
	def load_user_tags(user = nil)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
	  @tags_set_count = @tags_set.size
	end
	
	def load_user_contactors(user)
		@contactors_set = contactors_for(contacts_for(user, contact_conditions('1', '3'), 12, 'RAND()'))
		if @current_user
			current_user_contactors = contactors_for(contacts_for(@current_user, contact_conditions('1', '3'), 12, 'RAND()'))
			@mutual_contactors_set = @contactors_set & current_user_contactors
			@mutual_contactors_set_count = @mutual_contactors_set.size
			@contactors_set -= @mutual_contactors_set
		end
		@contactors_set_count = @contactors_set.size
	end
	
	def classify_recipes
		@classified_recipes = classified_items(@recipes_set, 'from_type')
	end
	
	def classify_favorite_statuses
		@classify_favorite_statuses = classified_favorite_statuses(@favorites_set)
	end
	
  def after_create_ok
  	self.current_user = @user
  	session[:user_id] = nil
  	respond_to do |format|
			format.html do
	      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收<em>#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}</em>!<br /><br/>
	      								 <em>如果偶尔未能收到#{ACCOUNT_CN}激活#{EMAIL_CN}</em>, 请发#{EMAIL_CN}到 #{SITE_EMAIL} 及时与我们联系..."				
				redirect_to root_path
			end
			# format.xml  { render :xml => @user, :status => :created, :location => @user }
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
			# format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
		end
  end
  
end
