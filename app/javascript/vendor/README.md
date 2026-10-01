Simple-DataTables 10.3.0 is vendored from its npm package `dist/module.js` as `simple_datatables.js`, with its LGPL-3.0 license alongside it. Its CSS is in `app/assets/tailwind/datatables.css`.

Upstream: https://github.com/fiduswriter/simple-datatables
Documentation: https://fiduswriter.github.io/simple-datatables/documentation/

Serve this module locally via the import map; no CDN or runtime npm installation is required. Keep the Stimulus controller on the outer `.table-wrap` container. The library moves/replaces the table during initialization and destruction, so placing the controller on the table can repeatedly disconnect and reconnect it. Tables containing editable inputs use a DOM-preserving search toolbar instead of re-rendering fields.
