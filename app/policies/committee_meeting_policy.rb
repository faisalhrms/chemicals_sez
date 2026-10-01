class CommitteeMeetingPolicy < ApplicationPolicy
  def show? = user.active?
  def create? = user.active? && user.developer?
  def update? = create?
  def destroy? = false
  def download? = show?
end
