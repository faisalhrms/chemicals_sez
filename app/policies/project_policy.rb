class ProjectPolicy < ApplicationPolicy
  def show?
    user.active?
  end

  def update?
    user.active? && user.developer?
  end

  def manage_documents?
    update?
  end
end
