# navtop

Handle the dynamics of site-level navigation bar. Need following DOMs:

 * `#nav-top nav` - navigation bar itself.
 * `#nav-top nav [ld-scope] - for rendering user information
   - update when
     - initializing, with information returned by `auth.get`
     - when receiving `auth.change` event from `auth`.
 
   - contains following lds:
     - displayname - menu item showing user display name
     - login - login menu item
     - signup - sign up menu item
     - "upgrade-now" - menu item for hinting user to upgrade
     - profile - menu item for link to user profile
     - avatar - node for showing user's avatar.
     - plan - node for showing user's plan name.
     - logout - logout menu item


Supported attributes over `#nav-top nav` element:

 * data-transition
   - two set of classes separated by `;` for applying over navigation bar before / after target element.
 * data-transition-target
   - selector for a target element.
     if provided, navbar will update its classes after scrolling across this target.
