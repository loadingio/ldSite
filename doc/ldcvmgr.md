# ldcvmgr

take care of ldCovers available in DOM or under `/modules/cover/`. HTMLs under `/modules/cover/` :

    .ldcv.ldcvmgr(data-name=<name>, data-lock=<lock>): ...

where:

  - `name`: the name of this cover
  - `lock`: true if user must interact with this cover to close it.

When initializing, ldcvmgr will:
 - search for DOMs with `.ldcvmgr` class, init a cover with their name from `data-name` attribute
 - search for DOMs with `[data-ldcv-toggle=<name>]` attribute and handle their clicks to toggle `name` covers.

## APIs

 * purge(name) - clear up cached `name` cover.
 * toggle(name,value,param) -
   - toggle `name` cover on with value `value`
   - fire event `ldcvmgr.<name>.[on|off]` with {cover, param} object.
 * is-on(name) - true if `name` cover is visible.
 * prepare 
   - fetch cover DOM from `/modules/cover/<name>.html` if not in cache.
   - called by `get`, `getdom`, `getcover` and `toggle`.
 * set(name,value) - resolve `name` cover with `value`.
 * get(name,param) - expect returned value from `name` cover. param used in event, as described in `toggle`.
 * getdom(name) - get DOM for `name` cover.
 * getcover(name) - get ldCover object for `name` cover.


## Actions

As methods in `lda.ldcvmgr` object:

 * toggle(name, val, param) - see above.
 * purge(name) - see above.
 * get(name, param) - see above.


