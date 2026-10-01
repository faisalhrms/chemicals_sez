# Sapphire production deployment

Repository: `git@github.com:faisalhrms/chemicals_sez.git`

Production is deployed with Capistrano as `sez@156.67.25.193` into `/apps/sapphire_chemical/sez`. Nginx serves `http://156.67.25.193:8083` and proxies to Puma on `127.0.0.1:3103`. The `sez-sapphire-chemical.service` systemd unit runs Ruby 4.0.5, which is supported by the Gemfile's Ruby 4.0 constraint. Development uses `.ruby-version`.

## Deploy an update

Commit and push changes to `main`, then run from the project with Ruby 4.0 and Bundler installed:

```sh
bundle exec cap production deploy
```

The deploy runs Brakeman and dependency checks locally, installs server gems, compiles assets, migrates the database, publishes a release, installs the service/Nginx configuration, validates Nginx, and restarts only Sapphire. It retains five releases. Routine deploys do not reset databases or run seeds.

## Server configuration

These protected server files are not committed:

- `shared/portal.env`: production runtime settings and secrets, mode 600.
- `shared/config/database.yml`: linked into releases; use `config/database.example.yml` with credentials supplied through the environment.
- `shared/run_with_portal_env`: loads `portal.env` for deployment commands.

Required settings include `SECRET_KEY_BASE`, `APP_HOST=156.67.25.193`, `APP_PORT=8083`, `FORCE_SSL=false`, `PUMA_BIND=tcp://127.0.0.1:3103`, `RAILS_ENV=production`, `RBENV_VERSION=4.0.5`, and database credentials. `WEB_CONCURRENCY=1` and `RAILS_MAX_THREADS=5` bound the application's process/thread usage.

The requested HTTP endpoint requires `FORCE_SSL=false`. HTTPS is the default when this setting is absent. For an HTTPS endpoint set `FORCE_SSL=true` and configure the proxy certificate. Authentication cookies follow the request protocol.

The service and site definitions are in `deployment/sez-sapphire-chemical.service` and `deployment/nginx.8083.conf`. Other applications on ports 8081 and 8082 are independent.

## Initial database and users

Create `sapphire_sez_portal_production` owned by the non-superuser role `sapphire_sez_portal`. Capistrano applies migrations. For the first deployment, provide unique passwords in `SEED_SUBMITTER_PASSWORD`, `SEED_REVIEWER_PASSWORD`, and `SEED_AUTHORITY_PASSWORD`, then explicitly run:

```sh
bundle exec cap production deploy:seed
```

Seeds create the project, twelve development categories, and three workspace users. Generated bootstrap credentials are kept in a protected server file and an ignored local deployment credentials file. They are never committed.

## Backup and verification

Before replacing an existing installation, archive its deployment files, storage, Nginx/site and service definitions, and take custom-format PostgreSQL dumps. Keep the backups outside the deployment directory. Database resets are one-time maintenance operations, never part of normal deployment or rollback tasks.

```sh
curl -f http://156.67.25.193:8083/up
ssh sez@156.67.25.193 'sudo systemctl status sez-sapphire-chemical --no-pager'
```

Verify sign-in for all three roles, table search/pagination, modals, report submission/approval redirects, and protected downloads. Browser regression instructions are in `test/browser/README.md`.

## Local setup

`config/database.yml` is ignored. `bin/setup` copies `config/database.example.yml` when missing. Set `DB_USER` and `DB_PASSWORD` for the development database before setup. Production credentials must remain in the server environment.
