class ContactsController < ApplicationController
  
	before_filter :protect, :except => [:index]
	before_filter :store_location_if_logged_in, :only => [:index, :mine]
	before_filter :clear_location_unless_logged_in, :only => [:index]
  before_filter :load_contact_type, :load_contactor
  before_filter :load_current_filter, :only => [:index, :mine]
  
  def index
    respond_to do |format|
      if @user && @user == @current_user
      	format.html { redirect_to :action => 'mine', :filter => @current_filter }
      else
		    load_contacts_set(@user)
		  	
		  	info = "#{username_prefix(@user)}#{PEOPLE_CN}"
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
						if Contact.friendship_request(@current_user, @contactor)
							page.replace_html "friendship_status_with_user_#{@contactor.id}", 
																:partial => '/contacts/contact_status', 
																:locals => { :contact_type => @contact_type, 
																						 :status => '2', 
																						 :user => nil, 
																						 :ref => params[:ref] }
						else
							page.replace_html "friendship_status_with_user_#{@contactor.id}", 
																:partial => '/contacts/contact_status', 
																:locals => { :contact_type => @contact_type, 
																						 :status => '-1', 
																						 :user => @contactor, 
																						 :ref => params[:ref] }
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
							page.redirect_to :controller => 'contacts', :action => 'mine', :filter => params[:filter]
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
							page.redirect_to :controller => 'contacts', :action => 'mine', :filter => params[:filter]
						end
					end
				end
			end
		end	
	end
	
  def mine
    load_contacts_set(@current_user)
    
  	@show_manage = true
		
		info = "#{username_prefix(@current_user)}#{PEOPLE_CN}"
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
  	@contacts_set = filtered_contacts(user, @current_filter)
  	@contacts_set_count = @contacts_set.size
  end
	
end
