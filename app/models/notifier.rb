class Notifier < ActionMailer::ARMailer
  include ActionController::UrlWriter
  def send_newsletter(user)
    setup_email(user)
    @subject    += "#{SITE_NAME_CN}的新功能"
    @body[:url]  = root_url
  end
  def newsletter(user, newsletter)
    setup_email(user)
    @subject = newsletter.subject
    @content_type = "text/html"
    @body [:body] = newsletter.body
    @body[:url]  = root_url
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
