class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.pending?
    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
    UserMailer.deliver_reset_password(user) if user.recently_reset_password?
    #重发激活邮件代码start
    UserMailer.deliver_resend_activemail(user) if user.resending?
    #重发激活邮件代码end
  end
end
