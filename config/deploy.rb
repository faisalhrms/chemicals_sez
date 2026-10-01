lock "~> 3.20.0"

set :application, "sapphire_sez_portal"
set :repo_url, "git@github.com:faisalhrms/chemicals_sez.git"
set :deploy_to, ENV.fetch("DEPLOY_TO", "/apps/sapphire_chemical/sez")
set :branch, ENV.fetch("BRANCH", "main")
set :keep_releases, 5
set :format, :airbrussh
set :log_level, :info

set :ruby_version, ENV.fetch("DEPLOY_RUBY_VERSION", "4.0.5")
set :default_env, {
  "RAILS_ENV" => "production",
  "RBENV_VERSION" => fetch(:ruby_version),
  "PATH" => "/home/sez/.rbenv/versions/#{fetch(:ruby_version)}/bin:/usr/local/bin:/usr/bin:/bin"
}

append :linked_files, "config/database.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage"

# Every remote Rails command loads the protected server environment.
set :bundle_bins, []
set :bundle_version, 4
set :bundle_jobs, 2
set :bundle_without, "development:test:deployment"
SSHKit.config.command_map[:bundle] = "#{shared_path}/run_with_portal_env bundle"
SSHKit.config.command_map[:rake] = "#{shared_path}/run_with_portal_env bundle exec rake"
SSHKit.config.command_map[:rails] = "#{shared_path}/run_with_portal_env bundle exec rails"

namespace :deploy do
  desc "Run application security checks before deployment"
  task :security_check do
    run_locally do
      execute RbConfig.ruby, Gem.bin_path("bundler", "bundle"), "exec brakeman -q -w2"
      execute RbConfig.ruby, Gem.bin_path("bundler", "bundle"), "exec bundler-audit check --update"
    end
  end

  desc "Install the Sapphire service and Nginx site, then restart"
  task :restart do
    on roles(:app) do
      execute :sudo, :install, "-m 644", release_path.join("deployment/sez-sapphire-chemical.service"), "/etc/systemd/system/sez-sapphire-chemical.service"
      execute :sudo, :install, "-m 644", release_path.join("deployment/nginx.8083.conf"), "/etc/nginx/sites-available/sez-sapphire-chemical"
      execute :sudo, :nginx, "-t"
      execute :sudo, :systemctl, "daemon-reload"
      execute :sudo, :systemctl, "enable", "sez-sapphire-chemical.service"
      execute :sudo, :systemctl, "restart", "sez-sapphire-chemical.service"
      execute :sudo, :systemctl, "reload", "nginx"
    end
  end

  desc "Seed the production project and bootstrap users (explicitly invoked)"
  task :seed do
    on roles(:db) do
      within current_path do
        execute :rake, "db:seed"
      end
    end
  end

  before :starting, :security_check
  after :publishing, :restart
end
