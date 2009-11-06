class UserMailer < ActionMailer::ARMailer
	include ActionController::UrlWriter
	include UsersHelper
  default_url_options[:host] = SITE_DOMAIN_EN
	
  def signup_notification(user)
    setup_email(user)
    @subject += "请激活你的#{SITE_NAME_CN}#{ACCOUNT_CN}"
    @body[:url] = "#{root_url}activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject += "恭喜你加入#{SITE_NAME_CN}"
    @body[:url] = user_first_link(user, false)
  end

	def forgot_password(user)
		setup_email(user)
    @subject += "请重新设置你的#{ACCOUNT_CN}#{PASSWORD_CN}"
    @body[:url] = "#{root_url}reset_password/#{user.password_reset_code}" 
	end

	def reset_password(user)
		setup_email(user)
    @subject += "你已经重新设置了#{ACCOUNT_CN}#{PASSWORD_CN}"
    @body[:url] = user_first_link(user, false)
	end
        
        #重发激活邮件代码start
        def resend_activemail(user)
          setup_email(user)
          @subject += "#{RESEND_CN}#{EMAIL_CN}"
          @body[:url]  = "#{root_url}activate/#{user.activation_code}"
        end
        #重发激活邮件代码end
	
	def friendship_request(contact)
		user = User.find(contact.user_id)
		contactor = User.find(contact.contactor_id)
		setup_email(user)
		@body[:url] = user_first_link(contactor, false)
		@subject += "#{contactor.login}向你发出了#{FRIEND_CN}请求"
		@body[:contactor] = contactor
	end
	
	def friendship_accept(contact)
		user = User.find(contact.user_id)
		contactor = User.find(contact.contactor_id)
		setup_email(user)
		@body[:url] = user_first_link(contactor, false)
		@subject += "#{contactor.login}接受了你的#{FRIEND_CN}请求"
		@body[:contactor] = contactor
	end

  def send_invite(mail,user)
    @recipients = "#{mail}"
	  @from = "#{user.login}"
	  @subject = "来自好友#{user.login}的加入蜂厨邀请"
	  @sent_on = Time.now
	  @content_type = "text/html"
	  @body[:user] = user
    @body[:url] = "#{root_url}signup?invite_id=#{user.id}"
  end

  protected
  
	def setup_email(user)
	  @recipients = "#{user.email}"
	  @from = "#{SITE_NAME_EN} <#{SITE_EMAIL}>"
	  @subject = "[#{SITE_NAME_CN}] "
	  @sent_on = Time.now
	  @content_type = "text/html"
	  @body[:user] = user
	end
end
