categories = [
  "Roads (Internal)",
  "Access Roads",
  "Boundary Wall",
  "Sewerage / drainage",
  "Wastewater Treatment",
  "Medical Facility",
  "Electricity",
  "Gas (Industrial & Commercial)",
  "Water",
  "Security",
  "Fire Fighting",
  "Telephone / DSL / Fiber"
]

categories.each_with_index do |name, index|
  DevelopmentCategory.find_or_create_by!(name: name) do |category|
    category.position = index + 1
    category.active = true
  end
end

Project.find_or_create_by!(zone_name: "Sapphire Value Addition Sole Enterprise Special Economic Zone") do |project|
  project.zone_developer = "Sapphire Chemicals (Private) Limited — SCPL"
  project.zone_type = "Sole Enterprise SEZ"
  project.ownership_type = "Private"
  project.notification_on = Date.new(2023, 7, 31)
  project.total_zone_area = "290 acres"
  project.zone_location = "Khushab, Punjab, Pakistan"
  project.zone_status = "Active"
  project.regulatory_framework = "Special Economic Zones Act 2012; Special Economic Zones Rules 2023"
  project.company_name = "Sapphire Chemicals (Private) Limited — SCPL"
  project.company_incorporated_year = 2022
  project.project_name = "Greenfield Soda Ash Manufacturing Plant"
  project.project_capacity = "200,000 TPA (200 KTPA)"
  project.project_location = "Warcha, Khushab District, Pakistan"
  project.project_cost = "Approx. USD 167 million"
  project.process_technology = "Synthetic — Solvay method"
  project.products = "Soda ash (light and dense), sodium bicarbonate"
  project.raw_materials = "Local rock salt, local limestone, water, coke, ammonia"
  project.export_potential = "USD 35 million per annum"
  project.market_positioning = "Import substitution for domestic soda ash market, with export offtake"
  project.employment_generation = "1,500 direct and indirect"
  project.notice_to_proceed_on = Date.new(2026, 4, 6)
  project.engineering_start_on = Date.new(2026, 4, 1)
  project.engineering_end_on = Date.new(2027, 3, 31)
  project.procurement_start_on = Date.new(2026, 4, 1)
  project.procurement_end_on = Date.new(2027, 9, 30)
  project.construction_start_on = Date.new(2026, 4, 1)
  project.construction_end_on = Date.new(2027, 12, 31)
  project.mechanical_completion_on = Date.new(2027, 12, 31)
  project.commissioning_start_on = Date.new(2028, 1, 1)
  project.commissioning_end_on = Date.new(2028, 4, 30)
  project.commercial_operations_on = Date.new(2028, 4, 14)
end

def seed_password(name)
  return ENV.fetch(name) if Rails.env.production?

  ENV.fetch(name, "ChangeMe!12345")
end

[
  [ "Developer Submitter", "submitter@sapphire.pk", :developer_submitter, "Associate Officer", seed_password("SEED_SUBMITTER_PASSWORD") ],
  [ "Developer Reviewer", "reviewer@sapphire.pk", :developer_reviewer, "Reviewer", seed_password("SEED_REVIEWER_PASSWORD") ],
  [ "Authority User", "authority@sapphire.pk", :authority, "Authority", seed_password("SEED_AUTHORITY_PASSWORD") ]
].each do |name, email, role, job_title, password|
  user = User.find_or_initialize_by(email_address: email)
  user.assign_attributes(name: name, role: role, job_title: job_title, active: true)
  if user.new_record?
    user.portal_layout = role == :developer_submitter ? :classic_sidebar : :modern_topbar
    user.password = password
    user.password_confirmation = password
  end
  user.save!
end

puts "Seeded project, development categories, and demo users."
puts "Development-only demo password: ChangeMe!12345" unless Rails.env.production?
