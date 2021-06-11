class MembershipsController < ApplicationController
  # Checkout表示のためのメアド入力ページ
  def new
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'subscription',
      success_url: "#{completed_memberships_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: new_membership_url,
      line_items: [{
        quantity: 1,
        price: ENV['STRIPE_PLAN_ID'],
      }],
      subscription_data: {
        trial_end: Time.current.next_month.next_month.beginning_of_month.to_i, # 翌々月初までトライアル
      }
    )
    @meta_title = '決済情報の登録'
    @no_index = true
  end


  # Checkoutでの決済情報登録完了時のリダイレクトページ
  def completed
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    session = Stripe::Checkout::Session.retrieve({id: params[:session_id], expand: ['customer']})

    user = User.find_or_initialize_by(email: session.customer.email)
    user.update!(stripe_customer_id: session.customer.id)

    redirect_to(root_path, flash: { success: '決済処理が完了しました！翌月初から1ヶ月間の無料トライアルを開始し、翌々月から課金を開始します。' })
  rescue => e
    logger.error "[Error]Stripe subscription failed. #{e}"
    redirect_to(new_membership_path, flash: { error: '決済処理に失敗しました。。課金処理を中止したため、これにより支払いが発生することはありません。' })
  end


  # Customer Portalの表示申請ページ
  def edit
  end


  # メアドを受け取ってCustomer Portalにリダイレクト
  def update
  end
end
