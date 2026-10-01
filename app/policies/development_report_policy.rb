class DevelopmentReportPolicy < ApplicationPolicy
  def index?
    user.active?
  end

  def show?
    return record.approved? if user.authority?

    user.developer?
  end

  def create?
    user.active? && user.developer?
  end

  def update?
    create? && record.editable?
  end

  def submit_for_review?
    update?
  end

  def review?
    user.active? && user.reviewer? && record.under_review? && record.submitted_by_id != user.id
  end

  def review_center_show?
    if user.reviewer?
      return true if review?
      return user.active? && record.reviewed_by_id == user.id
    end

    user.active? && user.developer? && record.submitted_by_id == user.id
  end

  def approve? = review?
  def revert? = review?

  def export?
    user.active? && user.authority? && record.approved?
  end

  def download_attachment?
    show? && record.attachment.attached?
  end

  class Scope < Scope
    def resolve
      return scope.where(status: :approved) if user.authority?
      return scope.all if user.developer?

      scope.none
    end
  end
end
