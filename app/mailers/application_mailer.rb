class ApplicationMailer < ActionMailer::Base
  default from: 'ブンゴウメール編集部 <bungomail@notsobad.jp>'
  # layout 'mailer'
  layout false
end
