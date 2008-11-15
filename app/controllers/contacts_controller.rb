class ContactsController < ApplicationController
  
	before_filter :protect, :except => [:index]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index]
  before_filter :load_contact_type, :load_contactor
  
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine' }
      else
		    load_contacts_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{FRIEND_CN} (#{@contacts_set_count})"
				set_page_title(info)
				set_block_title(info)
				
      	format.html # index.html.erb
      end
      # format.xml  { render :xml => @contacts_set }
    end 
  end
  
  def new
  	redirect_to user_profile_path(@user)
  end
  
	def create
		respond_to do |format|
			format.js do
				render :update do |page|
					if @contact_type == '1'
						page.replace_html "friendship_status_with_user_#{@contactor.id}", 
															:partial => '/contacts/contact_status', 
															:locals => { :contact_type => @contact_type, 
																					 :status => '0', 
																					 :user => nil, 
																					 :ref => 'user_bar' }
						if Contact.friendship_request(@current_user, @contactor)
							page.delay(2) do
								page.replace_html "friendship_status_with_user_#{@contactor.id}", 
																	:partial => '/contacts/contact_status', 
																	:locals => { :contact_type => @contact_type, 
																							 :status => '2', 
																							 :user => nil, 
																							 :ref => 'user_bar' }
							end
						else
							page.delay(2) do
								page.replace_html "friendship_status_with_user_#{@contactor.id}", 
																	:partial => '/contacts/contact_status', 
																	:locals => { :contact_type => @contact_type, 
																							 :status => '2', 
																							 :user => @contactor, 
																							 :ref => 'user_bar' }
							end
						end
					end
				end
			end
		end
		
		# UserMailer.deliver_friend_request(
		# :user => @user,
		# :friend => @friend,
		# :user_url => profile_for(@user),
		# :accept_url => url_for(:action => "accept", :id => @user.screen_name),
		# :decline_url => url_for(:action => "decline", :id => @user.screen_name)
		# )
	end
	
	def accept
		respond_to do |format|
			format.js do
				render :update do |page|
					if @contact_type == '1'
						if Contact.friendship_accept(@current_user, @contactor)
							page.replace_html "friendship_status_with_user_#{@contactor.id}", 
																:partial => '/contacts/contact_status', 
																:locals => { :contact_type => @contact_type, 
																						 :status => '3', 
																						 :user => @contactor, 
																						 :ref => 'contacts_list' }
							page.replace_html "contacts_header", 
																:partial => "/layouts/index_header", 
									 							:locals => { :show_header_link => false, 
									 						 							 :show_new_link => false, 
									 						 							 :block_title => "我的#{FRIEND_CN} (#{contacts_for(@current_user).size})" }
						end
					end
				end
			end
		end
	end
	
	def delete
		respond_to do |format|
			format.js do
				render :update do |page|
					if @contact_type == '1'
						if Contact.friendship_breakup(@current_user, @contactor)
							page.redirect_to ''
						end
					end
				end
			end
		end	
	end
	
  def mine
    load_contacts_set(@current_user)
    
  	@show_todo = true
  	@show_manage = true
		
		info = "#{username_prefix(@current_user)}#{FRIEND_CN} (#{@contacts_set_count})"
		set_page_title(info)
		set_block_title(info)
		
    respond_to do |format|
      format.html { render :template => "contacts/index" }
      # format.xml  { render :xml => @contacts_set }
    end
  end
  
	private
	
	def load_contact_type
		@contact_type = params[:contact_type] if params[:contact_type]
	end
	
	def load_contactor
		@contactor = User.find(params[:id]) if params[:id]
	end
	
  def load_contacts_set(user)
 		if user && user == @current_user
 			@contacts_set = contacts_for(user, contact_conditions('1'), nil, 'created_at DESC')
 			friends_set_count = contacts_for(user).size
 			@contacts_set_count = friends_set_count
 		else
 			@contacts_set = contacts_for(user, contact_conditions('1', '3'), nil, 'created_at DESC')
 			@contacts_set_count = @contacts_set.size
 		end
  end
	
end
