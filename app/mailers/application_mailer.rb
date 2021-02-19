class ApplicationMailer < ActionMailer::Base
  default from: 'ブンゴウメール編集部 <bungomail@notsobad.jp>', to: 'bungomail@notsobad.jp'
  layout false
end
