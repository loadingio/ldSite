# loader

public loader for abstracting between loading indicator and DOM. This public loader is `body` itself, so you can style the loader with something like `ldButton` provides.


## APIs

 - on - toggle loader on.
 - off - toggle loader off.
 - on-later(ms=500) - toggle loader on after `ms` milliseconds.
 - cancel - cancel `on-later` call.
