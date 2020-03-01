class ApplicationMailer < ActionMailer::Base
  default from: 'BungoMail <noreply@bungomail.com>'
  layout 'mailer'
end
