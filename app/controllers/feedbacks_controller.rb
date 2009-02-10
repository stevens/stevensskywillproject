class FeedbacksController < ApplicationController
	
	def new
		if @current_user
			@feedback = @current_user.feedbacks.build
		else
			@feedback = Feedback.new
		end
    
    info = "#{FEEDBACK_CN} - 我对#{SITE_NAME_CN}说"
		set_page_title(info)
		set_block_title(info)
    
    respond_to do |format|
      format.html # new.html.erb
      # format.xml  { render :xml => @feedback }
    end
	end
	
	def create
		if @current_user
    	@feedback = @current_user.feedbacks.build(params[:feedback])
    	@feedback.submitter_type = '2'
    else
    	@feedback = Feedback.new(params[:feedback])
    	@feedback.submitter_type = '1'
    end
    item_client_ip(@feedback)
    
		if @feedback.save
			after_create_ok
		else
			after_create_error
		end
	end

	private
	
  def after_create_ok
  	respond_to do |format|
			format.html do
				flash[:notice] = "非常感谢你对#{SITE_NAME_CN}的支持和帮助, 我们一定会\"好好努力 天天向上\"!"	
				redirect_to root_path
			end
			format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
		end
  end
  
  def after_create_error
  	respond_to do |format|
			format.html do
				flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的#{FEEDBACK_CN}信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
				
				info = "#{FEEDBACK_CN} - 我对#{SITE_NAME_CN}说"	
				set_page_title(info)
				set_block_title(info)
				
				render :action => "new"
				clear_notice
			end
			format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
		end
  end

end
