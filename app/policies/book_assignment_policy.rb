class BookAssignmentPolicy < ApplicationPolicy
  def skip?
    update?
  end
end
