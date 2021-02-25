class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user
  end

  def show?
    update?
  end

  def create?
    user
  end

  def new?
    create?
  end

  def update?
    user && user.id == record.user_id
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end
