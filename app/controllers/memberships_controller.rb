class MembershipsController < ApplicationController
  before_action :set_stripe_key

  # Checkout表示のための説明ページ
  def new
    @meta_title = '新規ユーザー登録'
    @no_index = true
  end


  # Checkoutに飛ばす前にcustomer作成
  def create
    customer = Stripe::Customer.create
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'setup',
      customer: customer['id'],
      success_url: "#{memberships_completed_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: memberships_new_url,
    )
    render layout: false
    @no_index = true
  end


  # Checkoutでの決済情報登録完了時のリダイレクトページ
  def completed
    redirect_to root_path and return unless params[:session_id]  # 直接アクセスしてきたらリダイレクト

    session = Stripe::Checkout::Session.retrieve({id: params[:session_id], expand: ['customer']})
    user = User.find_or_initialize_by(email: session.customer.email)
    raise "Customer #{user.stripe_customer_id} already exists." if user.stripe_customer_id.present?  # 重複登録 or 退会→再登録 の場合はとりあえず例外で手動対応
    user.update!(stripe_customer_id: session.customer.id)

    beginning_of_next_next_month = Time.current.next_month.next_month.beginning_of_month
    Stripe::Subscription.create({
      customer: session.customer.id,
      trial_end: beginning_of_next_next_month.to_i,
      items: [
        {price: ENV['STRIPE_PLAN_ID']}
      ],
    })

    redirect_to(root_path, flash: { success: '決済処理が完了しました！翌月初から1ヶ月間の無料トライアルを開始します。配信開始までしばらくお待ちください。' })
  rescue => e
    logger.error "[Error]Stripe subscription failed. #{e}"
    redirect_to(memberships_new_path, flash: { error: '決済処理に失敗しました。。課金処理を中止したため、これにより支払いが発生することはありません。解決しない場合は運営までお問い合わせください。' })
  end


  # Customer Portalの表示申請ページ
  def edit
    @meta_title = '決済情報の確認・更新'
    @no_index = true
  end


  # メアドを受け取ってCustomer PortalのURLをメール送信
  def update
    user = User.find_by(email: params[:email])
    if !user || !user.stripe_customer_id
      return redirect_to(memberships_edit_path, flash: { error: '入力されたメールアドレスで決済登録情報が確認できませんでした。解決しない場合は運営までお問い合わせください。' })
    end

    portal_session = Stripe::BillingPortal::Session.create(
      customer: user.stripe_customer_id,
      return_url: memberships_edit_url,
    )
    BungoMailer.with(user: user, url: portal_session.url).customer_portal_email.deliver_now

    redirect_to(memberships_edit_url, flash: { success: 'URLを送信しました。10分以上経過してもメールが届かない場合は運営までお問い合わせください' })
  end

  private

  def set_stripe_key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end
end
