# Security design and operating requirements

This project is hardened around the Rails 8.1 security guidance and common production controls. It is **not possible to guarantee that any non-trivial web application has zero vulnerabilities**. Security depends on code, configuration, deployment, dependencies, operating system patching, database permissions, secrets handling, and operational practice.

## Controls implemented in the application

### Authentication

- No public registration endpoint.
- Passwords use Rails `has_secure_password` / bcrypt.
- Minimum password length: 12 characters.
- Login rate limiting in Rails.
- Generic login and password-reset responses to reduce account enumeration.
- Password-reset tokens expire after 20 minutes.
- Successful password reset revokes all existing sessions.
- Sessions have a 12-hour absolute lifetime.
- Session cookie is signed, HttpOnly, SameSite=Lax, and Secure in production.
- Session is rotated at login.
- Deactivated users are denied and their sessions can be revoked immediately.

### Authorization

- Pundit policies guard every developer/authority module action.
- Authority can see only approved reports.
- Authority has no create/update/delete routes for DSR data.
- Review Center requires `developer_reviewer`.
- A reviewer cannot review their own submission.
- Approved reports are treated as immutable snapshots by the application.

### Request/browser protections

- Rails CSRF protection remains enabled.
- Production forces HTTPS/HSTS through Rails.
- HostAuthorization is enabled through `APP_HOST`.
- Strict Content Security Policy with local scripts/styles only.
- `X-Content-Type-Options: nosniff`.
- `X-Frame-Options: SAMEORIGIN`.
- restrictive Permissions-Policy.
- sensitive parameters are filtered from logs.

### Database/data integrity

- PostgreSQL foreign keys.
- database check constraints for roles, statuses and 0–100 completion values.
- unique user email enforcement at database level.
- one report item per category per report.
- no uniqueness constraint on reporting month: multiple submissions in one month are supported.
- workflow changes use transactions and row locking.
- explicit append-only audit events record important workflow/document actions.
- NOC and committee records can be corrected but are not deletable through the application, reducing accidental statutory-record loss.

### File uploads

- NOC, committee minutes and optional DSR attachments accept PDF only.
- 10 MB maximum file size at model level.
- Active Storage public routes are disabled.
- downloads pass through authorized controllers.
- downloads use `Content-Disposition: attachment`.
- Nginx example limits request body size.

For higher-assurance production environments, add malware scanning (for example, ClamAV or an enterprise scanning gateway) before making uploaded PDFs available for download.

## Required production practices

1. Never commit passwords, database credentials, API keys, private keys, `.env` files, or Rails master keys.
2. Use a dedicated PostgreSQL role with access only to this application's database.
3. Terminate TLS using a valid certificate and redirect all HTTP traffic to HTTPS.
4. Restrict SSH to key-based access and trusted source networks/VPN where possible.
5. Run the application as an unprivileged Linux account.
6. Keep PostgreSQL inaccessible from the public Internet.
7. Keep backups encrypted and test restoration regularly.
8. Patch Ruby/Rails/gems/Ubuntu/Nginx/PostgreSQL promptly.
9. Run `bin/security-check` before deployment.
10. Review user accounts and permissions periodically.
11. Monitor authentication failures and unusual download activity at the proxy/application log level.

## Security checks before each release

```bash
bundle exec brakeman -q -w2
bundle exec bundler-audit check --update
bundle exec rubocop
bin/rails test
```

Capistrano is configured to run Brakeman and bundler-audit locally before deployment starts.

## Dependency policy

The Gemfile intentionally uses a small set of mainstream dependencies. Fewer dependencies reduce maintenance burden and supply-chain exposure. Avoid adding gems for functionality Rails already provides unless there is a clear benefit.

## Reporting a vulnerability

For an internal deployment, report suspected vulnerabilities directly to the application owner/security team. Do not include production credentials, tokens, or confidential data in tickets or chat logs.

## Account self-service controls

- Profile updates are restricted to the currently authenticated user and do not expose role or permission fields.
- Sign-in email, role, workspace, active status, and review permissions are not editable from the profile UI.
- Avatar uploads are limited to JPG/JPEG, PNG, and WebP and a maximum of 3 MB; SVG is intentionally excluded.
- Password changes require the current password, have rate limiting, retain the existing minimum password length, and invalidate all other active sessions.
- Appearance preferences contain no authorization data. Switching layouts cannot grant access to routes or actions because Pundit/controller authorization remains server-side.
