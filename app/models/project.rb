class Project < ApplicationRecord
  has_many :nocs, dependent: :restrict_with_exception
  has_many :committee_meetings, dependent: :restrict_with_exception
  has_many :development_reports, dependent: :restrict_with_exception

  validates :zone_name, :zone_developer, :project_name, presence: true

  def display_name
    project_name.presence || zone_name
  end
end
