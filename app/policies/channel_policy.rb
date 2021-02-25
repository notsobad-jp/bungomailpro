class ChannelPolicy < ApplicationPolicy
  def index?
    true
  end

  # 公開チャネルか自分のチャネルのみ閲覧可能
  def show?
    record.channel_profile.present? || (user && user.id == record.user_id)
  end

  # proプランならChannel作成可能
  def create?
    user && user.membership.plan == 'pro'
  end
end
