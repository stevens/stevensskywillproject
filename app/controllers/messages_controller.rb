class MessagesController < ApplicationController
  before_filter :protect
  before_filter :find_unread_msg, :only => [:sent, :write, :show, :index]

  def find_unread_msg
    @unread_messages_set = @current_user.recieved_messages.find(:all, :conditions => "recipient_status = 1 and ifread = 1")
  end

  def index
    info = "#{MAILBOX_CN}-收件箱"
    set_page_title(info)
 #   set_block_title(info)
    @messages = @current_user.recieved_messages.find(:all, :conditions => "recipient_status = 1")
  end

  def sent
    info = "#{MAILBOX_CN}-发件箱"
    set_page_title(info)
#    set_block_title(info)
    @messages = @current_user.sent_messages.find(:all, :conditions => "sender_status = 1")
  end

  def delete
    begin
      @message = Usermessage.find(params[:id])
      if (@current_user == @message.sender)
        @ifsent = true
        @message.sender_status = 0
        @message.save
        redirect_to :action => "sent"
      elsif (@current_user == @message.recipient)
        @ifsent = false
        @message.recipient_status = 0
        @message.save
        redirect_to :action => "index"
      else
        flash[:notice] = "你没有权限访问这个页面。"
        redirect_to :action => "index"
      end
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "该#{MAILBOX_CN}不存在."
        redirect_to :action => "index"
    end
  end

  def show
    info = "#{MAILBOX_CN}"
    set_page_title(info)
    begin
      @message = Usermessage.find(params[:id])
      if (@current_user == @message.sender)
        @ifsent = true
        @msg_user = @message.recipient
      elsif (@current_user == @message.recipient)
        @ifsent = false
        @msg_user = @message.sender
        @message.ifread = 0
        @message.save
      else
        flash[:notice] = "你没有权限访问这个页面。"
        redirect_to :action => "index"
      end
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "该#{MAILBOX_CN}不存在."
        redirect_to :action => "index"
    end
  end

  def write
    info = "写#{MAILBOX_CN}"
    set_page_title(info)
    if !params[:reply].blank?
      @usermessage = Usermessage.find(params[:reply])
      if (@current_user == @usermessage.recipient)
        @ifreply = true
        @recipient_id = @usermessage.sender.id
        @msg_title = "Re:" + @usermessage.message.title
        @msg_comment = "" + @usermessage.sender.login + "说：\n>>  " + @usermessage.message.comment.gsub(/\n/,"\n>>  ")
      else
        flash[:notice] = "你没有权限访问这个页面。"
        redirect_to :action => "index"
      end
    else
      @ifreply = false
      @recipient_id = params[:to]
    end
    
  #  @message = Message.new
#    set_block_title(info)

#    respond_to do |format|
#      format.html # new.html.erb
      # format.xml  { render :xml => @user }
#    end
  end

  def create
    @message = Message.new(params[:message])
    @sender_id = params[:message][:from]
    @recipient_id = params[:message][:to]
    if Message.setup_msg(@message, @sender_id, @recipient_id)
#      @message.save
      flash[:notice] = "#{MAILBOX_CN}已成功发送."
      redirect_to :action => "index"
    else
#      redirect_to :action => "sent"
#      render :action => "write", :to => @recipient_id
      after_create_error
    end
  end

  def after_create_error
  	respond_to do |format|
      flash[:notice] = "#{SORRY_CN}, 你#{INPUT_CN}的信息有#{ERROR_CN}, 请重新#{INPUT_CN}!"
      info = "写#{MAILBOX_CN}"
      set_page_title(info)
      set_block_title(info)
			format.html do
				render :action => "write"
				clear_notice
			end
			# format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
		end
  end

end
