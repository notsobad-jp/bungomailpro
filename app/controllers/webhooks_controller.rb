class WebhooksController < ApplicationController
  protect_from_forgery with: :null_session

  # Stripe側でsubscriptionのステータスが変更されたのを拾ってDBに反映する（status以外の情報は更新しない）
  ## 1) トライアル終了（trialing→active）
  ## 2) 支払い失敗（active→past_due）
  ## 3) 支払い失敗→再支払（past_due→active
  ## 4) 支払い失敗→自動解約（past_due→canceled）
  def update_subscription
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_signature = Rails.env.production? ? ENV['STRIPE_WEBHOOK_SIGNATURE'] : ENV['STRIPE_WEBHOOK_SIGNATURE_TEST']

    # statusが変更されてない場合はスキップ
    return head :ok if !JSON.parse(payload)['data']['previous_attributes'].try(:has_key?, 'status')

    # webhookのsignatureチェック
    begin
      event = Stripe::Webhook.construct_event( payload, sig_header, webhook_signature)
    rescue JSON::ParserError => e
      # Invalid payload
      logger.error "[STRIPE Webhook] #{e}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      logger.error "[STRIPE Webhook] #{e}"
      return head :bad_request
    end

    # DBに変更を反映
    sub = event.data.object
    charge = Charge.find_by!(subscription_id: sub.id)
    charge.update(status: sub.status)

    return head :ok
  end
end
