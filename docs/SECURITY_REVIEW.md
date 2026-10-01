# Security review notes

Review date: 2026-09-29

The application follows the current Rails 8.1 security guidance and intentionally keeps the dependency set and custom JavaScript small. Security is defense-in-depth; no application can be guaranteed to be free of all vulnerabilities.

## Application controls reviewed

- Rails session rotation on successful login.
- Database-backed login sessions with a 12-hour absolute lifetime.
- Signed, HttpOnly, SameSite=Lax session identifier cookie; Secure in production.
- No public user registration.
- bcrypt password hashing through `has_secure_password`.
- Generic authentication and password-reset failures.
- Expiring password-reset tokens; password change revokes existing sessions.
- Rails and Nginx login/password-reset rate limits.
- Pundit authorization on every non-dashboard Developer/Authority action.
- Developer/Authority workspace separation.
- Maker-checker rule: a reviewer cannot approve their own DSR submission.
- Row locking around DSR review transitions to prevent competing reviewers from applying stale decisions.
- Approved DSRs are immutable snapshots.
- Project master data is view-only from the portal.
- Strong parameters on all write controllers.
- Rails CSRF protection left enabled.
- Strict Content Security Policy; no `unsafe-inline` or `unsafe-eval`.
- Importmap Subresource Integrity enabled for local JS assets through Propshaft SHA-256 integrity hashes.
- Production HTTPS/HSTS through Rails, plus Nginx TLS termination configuration.
- HostAuthorization using required `APP_HOST` in production.
- Conservative browser security headers and restrictive Permissions-Policy.
- No `raw`, `html_safe`, `eval`, dynamic constantization, inline JavaScript handlers, or JavaScript URLs in application code.
- Parameterized Active Record queries; no user-input SQL interpolation found in the source review.
- PostgreSQL foreign keys, unique indexes, enum/range checks, and reporting-month/report-date consistency checks.
- Active Storage public routes disabled; PDF downloads go through authorized controllers and use `private, no-store` caching.
- PDF uploads restricted to PDF content type + `.pdf` filename and 10 MB maximum size.
- Excel cells that can contain user-entered text are explicitly emitted as string cells to prevent formula interpretation.
- NOC and committee records can be corrected but are not deletable from the web UI, reducing accidental statutory-record loss.
- Append-only workflow/document audit events.
- Brakeman, bundler-audit, RuboCop and the Rails test suite are included in CI and the pre-deploy security workflow.

## Static checks completed in the build environment

The following checks were completed successfully on the generated source:

- Ruby syntax parse for all Ruby/config/rake files.
- JavaScript syntax parse for all Stimulus/application JavaScript files.
- JSON and non-ERB YAML parsing.
- scan for common dangerous constructs (`html_safe`, `raw`, `eval`, dynamic constantization and inline event handlers).
- scan for committed private-key blocks.

## Runtime verification required before production

The generation environment does not have Ruby 4.0.7, Rails 8.1.4, PostgreSQL, or Internet gem access available, so it was not possible here to execute `bundle install`, Rails migrations, the complete Minitest suite, Brakeman, or bundler-audit against an installed dependency graph.

Before the first deployment on a networked Ruby 4.0.7 workstation/server, run:

```bash
bundle install
bin/rails db:prepare
bin/rails test
bundle exec rubocop
bundle exec brakeman -q -w2
bundle exec bundler-audit check --update
bin/rails tailwindcss:build
```

Commit the generated `Gemfile.lock` after the first successful `bundle install` and use that lockfile for CI and production deployments.

For production deployments that accept documents from users outside a tightly controlled trusted group, add malware scanning (such as an enterprise upload scanning gateway or ClamAV integration) before released documents are downloadable.
