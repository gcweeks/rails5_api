class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    attachments.inline['logo.png'] = File.read('./app/assets/images/logo.png')
    attachments.inline['divider.png'] = File.read('./app/assets/images/divider.png')
    mail(to: @user.email, subject: 'Welcome to SomeCompany 🎉')
  end

  def password_reset(user, code)
    @user = user
    @code = code
    attachments.inline['logo.png'] = File.read('./app/assets/images/logo.png')
    attachments.inline['divider.png'] = File.read('./app/assets/images/divider.png')
    mail(to: @user.email, subject: 'Password Reset')
  end
end
