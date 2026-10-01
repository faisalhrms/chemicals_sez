Run against a local development portal with the demo submitter account:

```sh
npm --prefix test/browser ci
npx --prefix test/browser playwright install chromium
npm --prefix test/browser test
```

Optional environment variables: `PORTAL_BASE_URL` (defaults to http://localhost:3000), `PORTAL_SUBMITTER_EMAIL`, `PORTAL_PASSWORD`, and `CHROME_PATH` for an existing Chrome executable.

The check reads portal pages and signs in, but does not create or update business records. Temporary tables exist only in the browser. It checks search, pagination, date sorting, preservation of unsaved inputs, idle DOM mutations, cleanup, repeated Turbo navigation, and browser back navigation. It always closes its browser.
