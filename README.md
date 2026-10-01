# Sapphire SVA SEZ Development Monitoring Portal

A production-oriented Ruby on Rails application based on the supplied Sapphire Value Addition (SVA) Sole Enterprise Special Economic Zone portal mockups.

## Functional scope

### Developer workspace

The Developer home screen intentionally stays simple and uses four large modules:

1. **Project Details** — fixed SEZ/project information, NOCs, committee meetings/minutes, and recent DSR records.
2. **Progress Update** — create month-wise Development Status Reports (DSR), copy the latest approved values into a new draft, edit 12 development categories, and submit for review.
3. **Review Center** — visible only to Developer Reviewer users; approve/forward or revert reports with comments.
4. **Submission Records** — month-wise history with every non-draft submission shown latest first.

### Authority workspace

Authority is read-only and can:

- view Project Details, NOCs, committee minutes, and approved DSRs;
- view all approved submissions month-wise;
- export an approved DSR to Excel;
- download authorized PDF attachments.

## Roles

The application has two login workspaces but supports three account roles:

- `developer_submitter` — enter data, manage NOCs/committee minutes, create/edit/submit DSRs.
- `developer_reviewer` — all Developer capabilities plus Review Center approval/reversion.
- `authority` — read-only Authority workspace.

A reviewer is intentionally blocked from approving their own submission (maker-checker control).

## Reporting model

`reporting_month` and `report_date` are separate fields.

Example:

- Reporting month: September 2026
- Report date: 03-09-2026
- Another September submission: 14-09-2026

Multiple reports in one month are supported. Report date must fall inside its reporting month. Every approved report remains a historical snapshot.

## Technology

- Ruby `4.0.7`
- Rails `8.1.4`
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Pundit authorization
- Active Storage for private PDF files
- CAXLSX for Excel export
- Puma
- Capistrano + capistrano3-puma for deployment
- Minitest
- Brakeman + bundler-audit + RuboCop in CI

Authentication uses Rails' built-in `has_secure_password` approach rather than adding a separate authentication framework. There is no public sign-up route.

## Local setup

### Requirements

- Ruby 4.0.7
- PostgreSQL 14+ (17 recommended for a new server)
- build tools required by Ruby/pg

### Install

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails tailwindcss:build
bin/dev
```

After the first successful `bundle install`, commit the generated `Gemfile.lock`. The source bundle was generated in an offline environment, so a trustworthy dependency lockfile could not be produced or runtime-tested there.

Open `http://localhost:3000`.

Development-only seeded accounts:

| Workspace | Role | Email | Password |
|---|---|---|---|
| Developer | Submitter | `submitter@sapphire.pk` | `ChangeMe!12345` |
| Developer | Reviewer | `reviewer@sapphire.pk` | `ChangeMe!12345` |
| Authority | Authority | `authority@sapphire.pk` | `ChangeMe!12345` |

These defaults are refused by the seed file in production: production seeding requires password environment variables.

## Create production users

No self-registration is exposed. Create users from the server console/task:

```bash
bin/rails users:create \
  EMAIL=user@sapphire.pk \
  NAME="User Name" \
  ROLE=developer_submitter \
  PASSWORD='a-long-unique-password'
```

Valid roles:

```text
developer_submitter
developer_reviewer
authority
```

Deactivate a user and revoke all sessions:

```bash
bin/rails users:deactivate EMAIL=user@sapphire.pk
```

## Tests and security checks

```bash
bin/rails test
bundle exec rubocop
bundle exec brakeman -q -w2
bundle exec bundler-audit check --update
```

Or run all checks:

```bash
bin/security-check
```

## Production deployment

See [DEPLOYMENT.md](DEPLOYMENT.md).

## Security

See [SECURITY.md](SECURITY.md) and [docs/SECURITY_REVIEW.md](docs/SECURITY_REVIEW.md). Security is treated as defense-in-depth; no web application can honestly be guaranteed to have zero vulnerabilities. Keep Ruby, Rails, PostgreSQL, OS packages, and gems patched and run the included security checks on every release.

## Frontend UI

The authenticated portal uses the approved simple enterprise layout:

- dark left navigation sidebar
- compact top header with current user/workspace
- Developer dashboard with four large clickable module cards
- permission-based Review Center visibility
- tabbed Project Details (SEZ, overview, timeline, NOCs, committee meetings, submitted reports)
- month-wise Progress Updates and Submission Records
- tabbed Under Review / Reviewed Review Center
- clear Reject/Revert and Approve & Forward actions
- read-only Authority report view with Excel export
- responsive mobile sidebar powered by a small Stimulus controller

The frontend intentionally uses Rails ERB + Hotwire/Stimulus + Tailwind and avoids a separate SPA framework to keep maintenance and debugging simple.

## Personal profile and appearance

Each signed-in user has a self-service account menu with:

- **My Profile** — update display name, phone, job title, and a JPG/PNG/WebP profile photo up to 3 MB.
- **Appearance** — switch between **Classic Sidebar** and **Modern Top Navigation**, choose System/Light/Dark theme, and choose Comfortable/Compact table density.
- **Security** — change password after confirming the current password. Changing the password closes the user's other active sessions.

Appearance settings are stored in PostgreSQL on the user record, so they follow the user across browsers/devices. Both layouts use the same controllers, views, authorization policies, and business logic; only the navigation shell changes.

After updating from an earlier ZIP, run:

```bash
bin/rails db:migrate
bin/rails tailwindcss:build
bin/dev
```

## UI/CSP notes

- The portal ships with both Classic Sidebar and Modern Top Navigation layouts.
- Authenticated shells use a fixed viewport with an independently scrolling content area, so long forms do not stretch the sidebar/header.
- Dashboard content is centered on wide displays and remains responsive on smaller screens.
- The bundled Sapphire Chemicals logo is used in login and portal navigation.
- Authority Project Details are rendered read-only; Developer Project Details remain editable and persisted through the existing update actions.
- `javascript_importmap_tags` is intentionally called without a `nonce:` keyword. importmap-rails 2.2.x attaches the request CSP nonce internally to its generated import-map/module tags. Rails nonce auto-attachment is enabled for standard Rails script/style helpers.
