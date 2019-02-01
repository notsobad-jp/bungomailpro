class WebhooksController < ApplicationController
  protect_from_forgery with: :null_session

  # Stripe側でsubscriptionのステータスが変更されたのを拾ってDBに反映する
  ## 1) トライアル終了（trialing→active）
  ## 2) 支払い失敗（active→past_due）
  ## 3) 自動解約（past_due→canceled）
  def update_subscription
    event_json = JSON.parse(request.body.read)

    # statusが変更されてない場合はスキップ
    return head 200 if !event_json['data']['previous_attributes'].has_key?('status')

    # 不正対策のためにEventオブジェクトをStripeから取り直す
    begin
      event = Stripe::Event.retrieve(event_json['id'])
    rescue Stripe::InvalidRequestError => e
      logger.error "[STRIPE] Event not found: #{e}"
      return head 500
    end

    # DBに変更を反映
    sub = event.data.object
    charge = Charge.find_by(subscription_id: sub.id)
    charge.update(status: sub.status)

    return head 200
  end
end
