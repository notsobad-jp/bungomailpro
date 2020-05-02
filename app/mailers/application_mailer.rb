class ApplicationMailer < ActionMailer::Base
  default from: 'BungoMail <noreply@bungomail.com>', template_path: 'mailing/user_mailer'
  layout false
end
