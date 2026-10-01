namespace :users do
  desc "Create a portal user. Example: bin/rails users:create EMAIL=x NAME='Name' ROLE=developer_submitter PASSWORD='...12 chars...'"
  task create: :environment do
    email = ENV.fetch("EMAIL")
    name = ENV.fetch("NAME")
    role = ENV.fetch("ROLE")
    password = ENV.fetch("PASSWORD")

    unless User.roles.key?(role)
      abort "ROLE must be one of: #{User.roles.keys.join(', ')}"
    end

    user = User.create!(
      email_address: email,
      name: name,
      role: role,
      password: password,
      password_confirmation: password,
      active: true
    )

    puts "Created user ##{user.id}: #{user.email_address} (#{user.role})"
  end

  desc "Deactivate a portal user and revoke all sessions. Example: bin/rails users:deactivate EMAIL=x"
  task deactivate: :environment do
    user = User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase)
    user.transaction do
      user.update!(active: false)
      user.sessions.delete_all
    end
    puts "Deactivated #{user.email_address}"
  end
end
