# auth 

take care of authpanel form, consent and provide authentication flow APIs. Need following DOMs:

 * `[ld-scope=cookie-consent]` - for cookie consent information. omit if not presented.
 * `.authpanel` - auth panel with password forms. form should contain following DOMs:
   - `input[name=email]`
   - `input[name=passwd]`
   - `input[name=displayname]`
   - `.btn[data-action=submit]`
   - `input[name=newsletter][type=checkbox]` (optional)


## API

auth provides following APIs:

 * init(opt) - setup additional information with `opt`. currently opt only supports:
   - root - authpanel root selector/DOM. this is for pages with static authpanel ( instead of a popup, auto-created one )
 * fetch(opt={renew: true}) - fetch user data, either from server or cookie.
   - cookie is stored in `global` variable. fetch will try getting data from cookie only if `renew` is `false`.
   - if `renew` is `true`, fetch user data from `/d/global`
   - resolve `get` requests if necessary.
   - tips:
     - always renew if we need the latest user data from server.
     - for quick first time data for website rendering, set renew = false to use data from cookie.

 * userinfo
   - organize user related information from global info. include following fields along with original user object:
     - plan - plan object
     - authed - boolean ( user.key > 0 )
     - is-pro - boolean ( /pro/.exec(plan.slug) )
     - is-blocked - boolean ( user.config.blocked )

 * get(opt={authed: false})
   - use to get user data, regardless if fetch or not.
     - it pends if `fetch` hasn't been called until `fetch` is called.
     - use `get` to get user data when we expect quick data from client side.
   - get authentication information and CSRF Token. options:
     - authed: authpanel will be shown if user isn't logged in when true 
     - info: information shown in authpanel if panel is shown.
     - tab: either `signup` or `login`. indicate the default tab to toggle when authpanel is shown.
   - expected fields in returned object:
     - location - 'tw' or other for now.
     - ip - user IP address.
     - user object
     - production - true or false.
     - csrfToken

 * ensure(opt)
   - ensure user is logged in. equivalent to get(opt <<< {authed: true})
     always popup authpanel if user is not logged in.

 * logout - simply logout user.
 * social(name) - sign user in with social login. name should be the name of social login method, including:
   - google
   - facebook
 * google - shorthand for `social('google')`
 * fb - shorthand for `social('facebook')`
 * switch(act) - toggle tab in authpanel. act should be one of `login` or `signup`.
 * fire - fire event. 
 * on(name, cb) - event listener. possible events:
   - `auth.signin`
   - `aith.change`

 * recaptcha: recaptcha submodule. with following methods:
   - init - initialization of recaptcha submodule. user usually won't need this.
   - get - get token required for recaptcah.
     - resolve to '' if recaptcha not enabled.
     - automatically initialize if not yet initialized.

 * consent: (opt = {}): ask user for consent.
   - config:
     - ldsite.consent[type]:
       - timing: <[ ... ]> ( e.g., signin )
       - url: .... ( pdf url )
       - cover: cover name for user to review and agree
   - opt:
     - type: what kind of consent is it? default tos
     - force: should we force popup consent cover? default false
     - timing: timing of this invocation.
     - bypass: true to bypass modal and update user object directly. should ONLY be used after user creation.


## Actions

As methods in `lda.auth` object:

 * fb, google, logout - as described above.
 * is-on - true if authpanel is visible.
 * show(action, info) - show authpanel.
   - action: either `signup` or `login`
   - info: name of information to show. also see `info` method.
 * hide(val) - close authpanel, with optional returned value `val`.
 * info(name)
   - toggle information in authpanel by `name`.
     named information can be added under an element with `[data-info=<name>]` attribute.

