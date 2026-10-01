server ENV.fetch("DEPLOY_HOST", "156.67.25.193"),
  user: ENV.fetch("DEPLOY_USER", "sez"),
  roles: %w[app web db],
  primary: true

set :ssh_options, {
  forward_agent: false,
  auth_methods: %w[publickey]
}
