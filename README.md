# ldSite

necessary frontend cores for a generic website, including:

 * `auth` - for authentication
 * `ldcvmgr` - cover(modal/dialog) handler
 * `error` - error handler ( by showing corresponding cover )
 * `loader` - public loader for used by any cores.
 * `notify` - notification handler ( a small, colored alert drops-in with short message )
 * `recaptcha` - recapthca information
 * `navtop` - navbar controller for
   - update user information
   - handle style change when scrolling across document
 * other utility functions:
   - URL parser
   - Cookie parser

You can find corresponding documentation under `doc` folder.

# Covers

Cores in ldSite use following covers through ldcvmgr:

 * logout
 * error
 * server-down
 * contact
 * error-413
 * error-403
 * error-400
 * assets-quota-exceeded
 * csrftoken-mismatch
 * authpanel
