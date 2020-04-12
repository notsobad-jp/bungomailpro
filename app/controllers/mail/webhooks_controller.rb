class Mail::WebhooksController < Mail::ApplicationController
  protect_from_forgery except: :update_subscription

  # subscription変更時にDBのstatusに最新の状態を反映する
  ## 1) トライアル終了（trialing→active）
  ## 2) 支払い失敗（active→past_due）
  ## 3) 支払い失敗→再支払（past_due→active
  ## 4) 支払い失敗→自動解約（past_due→canceled）
  ## 5) キャンセル（subscription.deleteイベントなので、status変更はなし）
  def update_subscription
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      # webhookのsignatureチェック
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_SIGNATURE'])
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      logger.error "[Webhook] #{e}"
      return head :bad_request
    end

    # DBに変更を反映
    sub = event.data.object
    charge = Charge.find_by!(subscription_id: sub.id)
    charge.update(status: sub.status)
    logger.info "[Webhook] UPDATED charge:#{charge.id}, SET status: #{sub.status}"

    head :ok
  end
end
