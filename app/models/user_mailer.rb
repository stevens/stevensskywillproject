class UserMailer < ActionMailer::Base
	include ActionController::UrlWriter
  default_url_options[:host] = SITE_DOMAIN_EN
	
  def signup_notification(user)
    setup_email(user)
    @subject    += "请激活你的#{SITE_NAME_CN}#{ACCOUNT_CN}"
    @body[:url]  = "#{root_url}activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "恭喜你加入#{SITE_NAME_CN}"
    @body[:url]  = root_url
  end

	def forgot_password(user)
		setup_email(user)
    @subject    += "请重新设置你的#{PASSWORD_CN}"
    @body[:url]  = "#{root_url}reset_password/#{user.password_reset_code}" 
	end

	def reset_password(user)
		setup_email(user)
    @subject    += "你已经重新设置了#{PASSWORD_CN}"
	end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{SITE_NAME_EN} <#{SITE_EMAIL}>"
      @subject     = "[#{SITE_NAME_CN}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
