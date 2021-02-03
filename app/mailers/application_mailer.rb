class ApplicationMailer < ActionMailer::Base
  default from: 'BungoMail <noreply@bungomail.com>'
  # layout 'mailer'
  layout false
end
