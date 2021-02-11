class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  
  default from: 'ブンゴウメール編集部 <bungomail@notsobad.jp>'
  layout false
end
