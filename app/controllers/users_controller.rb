class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :protect, :only => [:share]
	before_filter :clear_location_unless_logged_in, :except => [:share]
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
  
#  def show
#
#  end
  
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
    item_client_ip(@user)
    current = Time.now
    if !@user.client_ip.blank?
      same_ip_conditions_list = [ "users.client_ip = '#{@user.client_ip}'",
                                  "users.created_at >= '#{time_iso_format(current.beginning_of_day)}'",
                                  "users.created_at <= '#{time_iso_format(current.end_of_day)}'" ]
      same_ip_users = User.find(:all, :limit => 20,
                                :conditions => same_ip_conditions_list.join(' AND '))
      if same_ip_users.size < 20
        if @user.save
          after_create_ok
        else
          after_create_error
        end
      else
        @exceed_same_ip_limit = true
        after_create_error
      end
    else
      if @user.save
        after_create_ok
      else
        after_create_error
      end
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
	      flash[:notice] = "#{@user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!<br /><br/>
	      								 如果偶尔未能收到#{ACCOUNT_CN}激活#{EMAIL_CN}, 请查看 <a href='#{help_url}'>用户指南</a> , 或者通过 <a href='#{feedback_url}'>反馈</a> 与#{SITE_NAME_CN}联系..."
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
#	  load_random_users
	  
  	# @highlighted_user = 
  	# @highest_rated_users = 
  	# @random_users = random_items(@users_set, 12)
	  
	  info = "#{PEOPLE_CN}"
		set_page_title(info)
		
		show_sidebar
  end
  
  def profile
  	if @user && @user.accessible?
	    respond_to do |format|
	      if @user == @current_user
	      	format.html { redirect_to :controller => 'mine', :action => 'profile' }
	      else
          feed = rss_feed(profile_blog(@user))
          read_rss_items(feed, 5)

			  	load_user_recipes(@user)
          load_user_love_recipes(@user)
          load_user_menus(@user)
			  	# classify_recipes
			  	load_user_reviews(@user)
			  	load_user_favorites(@user)
			  	# classify_favorite_statuses
				 	load_user_tags(@user)
				 	load_user_contactors(@user)
				 	load_user_matches(@user)
				 	
				 	log_count(@user)
				 	
				 	info = "#{username_prefix(@user)}#{MAIN_PAGE_CN}"
					set_page_title(info)
					
					show_sidebar
					
	      	format.html # profile.html.erb
				end
			end
		end
  end

	#分享
	def share
    if @user && @user.accessible?
      info = "分享#{MAIN_PAGE_CN} - #{user_username(@user, true, true)}"
      set_page_title(info)
      set_block_title(info)
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
  
#  def load_random_users
#  	@random_users = users_for(user_conditions, 12, 'RAND()')
#  end

	def load_user_recipes(user = nil)
		@recipes_set = recipes_for(user)
		@recipes_set_count = @recipes_set.size
	end
        
  #### load love recipes of the user
  def load_user_love_recipes(user = nil)
    @love_recipes_set = love_recipes(user, '21')
    @love_recipes_set_count = @love_recipes_set.size
  end
  ### end

	def load_user_menus(user = nil)
    menu_conditions = common_filter_conditions(nil, 'Menu', user)
    @menus_set = menus_for(user, menu_conditions.join(' AND '), 12)
  	@menus_set_count = @menus_set.size
	end
	
	def load_user_reviews(user = nil)
		@reviews_set = filtered_reviews_set(user)[0..19]
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
		@contactors_set = contactors_for(contacts_for(user, contact_conditions('1', '3'), nil, 'RAND()'))
		if @current_user
			current_user_contactors = contactors_for(contacts_for(@current_user, contact_conditions('1', '3'), nil, 'RAND()'))
			@mutual_contactors_set = @contactors_set & current_user_contactors
			@contactors_set -= @mutual_contactors_set
      @mutual_contactors_set_count = @mutual_contactors_set.size
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
	      flash[:notice] = "#{@current_user.login}, 请到你的#{EMAIL_ADDRESS_CN} (#{@user.email}), 查收#{SITE_NAME_CN}#{ACCOUNT_CN}激活#{EMAIL_CN}!<br /><br/>
	      								 如果偶尔未能收到#{ACCOUNT_CN}激活#{EMAIL_CN}, 请查看 <a href='#{help_url}'>用户指南</a> , 或者通过 <a href='#{feedback_url}'>反馈</a> 与#{SITE_NAME_CN}联系..."
				redirect_to root_path
			end
			# format.xml  { render :xml => @user, :status => :created, :location => @user }
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do
        if @exceed_same_ip_limit
          flash[:notice] = "#{SORRY_CN}, 今天你已经超过了注册#{ACCOUNT_CN}的数量上限!"
        else
          flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{ACCOUNT_CN}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
        end
				
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
