class UserMailer < ActionMailer::Base
	include ActionController::UrlWriter
  default_url_options[:host] = SITE_DOMAIN_EN
	
  def signup_notification(user)
    setup_email(user)
    @subject    += "请确认你的#{SITE_NAME_CN}#{ACCOUNT_CN}#{SIGN_UP_CN}信息!"
    @body[:url]  = "#{root_url}users/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "恭喜你加入#{SITE_NAME_CN}!"
    @body[:url]  = root_url
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{SITE_NAME_EN} <#{SITE_EMAIL}>"
      @subject     = "[#{SITE_NAME_EN}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
