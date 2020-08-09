({ldsite,ldcvmgr,loader,util,error}) <- ldc.register \auth, <[ldsite ldcvmgr loader util error]>, _

#prevent global object been altered accidentally
global = -> if lc.global => JSON.parse(JSON.stringify lc.global) else null
[lc,el] = [{}, {}]

recaptcha = do
  lc: ready: false, queue: [], tag: null, sitekey: null, global: null, enabled: true, inited: false
  init: ->
    if @lc.inited => return Promise.resolve!
    auth.get!
      .then (g) ~> @lc <<< {global: g, sitekey: g.{}recaptcha.sitekey, enabled: g.{}recaptcha.enabled}
      .then ~>
        if !(@lc.enabled and @lc.sitekey) or @lc.tag => return
        @lc.tag = tag = document.createElement("script")
        tag.onload = ~>
          <~ grecaptcha.ready _
          @lc.ready = true
          @lc.queue.map -> it.res!
          @lc.queue.splice 0
        tag.setAttribute \type, "text/javascript"
        tag.setAttribute \src, "https://www.google.com/recaptcha/api.js?render=#{@lc.sitekey}"
        document.body.appendChild tag
      .then ~> @lc.inited = true
  get: (action = \generic) ->
    @init!
      .then ~>
        if !(@lc.sitekey and @lc.enabled) => return Promise.resolve('')
        p = if @lc.ready => Promise.resolve! else new Promise (res, rej) ~> @lc.queue.push {res, rej}
        p
          .then ~>
            grecaptcha.execute @lc.sitekey, {action}
          .then (token) -> return token


# cookie consent
cookie-consent = do
  dom: ld$.find document, '[ld-scope=cookie-consent]', 0
  val: util.cookie(\consent.cookie)
  clear: -> if @dom => ld$.remove(@dom); @dom = null
  check: ->
    ({user}) <~ auth.get!then _
    if user.{}config.{}consent.cookie and @dom => return @clear!
    if !(@val = util.cookie(\consent.cookie)) => return
    if ((user.{}config.{}consent.cookie) or !user.key) => return
    ld$.fetch("#{auth.api}/me/config", {method: \POST}, {json: {type: \consent, name: <[cookie]>}})
      .then (ret = {}) ~>
        user.{}config <<< ret
        util.cookie(
          \consent.cookie
          (ret.{}config.{}consent.cookie or Date.now!)
          new Date(Date.now() + 86400000 * 365 * 100).toGMTString()
        )
      .catch(->)
  init: ->
    if !@val and @dom => @dom.classList.remove \d-none else return
    <~ ld$.find(@dom, '[ld=ok]', 0).addEventListener \click, _
    @clear!
    @check!
cookie-consent.init!

init-authpanel = (dom) ->
  authpanel = lc.authpanel = if dom => that else ld$.find document, \.authpanel, 0
  if !lc.authpanel or lc.inited => return
  lc.inited = true


  acts = ld$.find authpanel, '[data-action]'
  authpanel.addEventListener \click, (e) ->
    if !e or !(n = e.target) or !e.target.getAttribute => return
    act = e.target.getAttribute \data-action
    auth.switch act

  # typical auth check flow
  lc.form = form = new ldForm do
    names: -> <[email passwd displayname]>
    after-check: (s, f) ->
      if s.email != 1 and !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(f.email.value) => s.email = 2
      if s.passwd != 1 =>
        if auth.act == \signup and "#{f.passwd.value}".length < 8 => s.passwd = 2
        else s.passwd = if !f.passwd.value => 1 else 0
      if auth.act == \login => s.displayname = 0
      else s.displayname = if !f.displayname.value => 1 else if !!f.displayname.value => 0 else 2
    root: authpanel
  el.submit = ld$.find(authpanel, '[data-action=submit]', 0)
  ldld = new ldLoader root: el.submit
  form.on \readystatechange, -> el.submit.classList.toggle \disabled, !it
  form.field('passwd').addEventListener \keyup, (e) ->
    if e.keyCode == 13 => form.check {now: true} .then -> submit!
  el.submit.addEventListener \click, -> submit!
  submit = ->
    if !form.ready! => return
    ldld.on!
    val = form.values!
    body = {} <<< val{email, passwd, displayname} <<< {config: {newsletter: val.newsletter}}
    body.passwd = body.passwd.replace(/\t*$/,'')
    recaptcha.get \signin
      .then (recaptcha) ->
        # dunno why but some users have a literal tab in its password field, which cause problem here.
        # try to remove all of them.
        body.recaptcha = recaptcha
      .then -> auth.consent {timing: \signin}
      .then ->
        ld$.fetch (if auth.act == \login => "#{auth.api}/u/login" else "#{auth.api}/u/signup"), {
          method: \POST
          body: JSON.stringify(body)
          headers: { 'Content-Type': 'application/json; charset=UTF-8' }
        }, {type: \text}
      .then -> auth.fetch!
      .then -> auth.get!
      .then (g) ->
        action.info \default
        if g.user => lda.auth.hide \ok
        form.reset!
        ldld.off!
      .then -> auth.consent {timing: \signin, bypass: true}
      .then -> auth.fire("auth.signin")
      .catch ->
        if auth.act == \signup => action.info \signup-failed
        else action.info \failed
        form.fields.passwd.value = null
        form.check {n: \passwd, now: true}
        ldld.off!

# get global object. put it here so it can't be resolved by user from dev console.
get = proxise -> if lc.global => return Promise.resolve lc.global

# typical auth chek flow
# get -> auth.show -> authpanel.show -> authpanel resolved -> ldc.auth.fetch -> get.resolved
auth = do
  api: (if ldsite => ldsite.api else \d).replace(/\/$/,'')
  init: (opt={}) ->
    if !opt.root => return
    root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
    init-authpanel root

  evt-handler: {}
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  manually-init: (opt = {}) ->
    if !opt.root => return
    root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
    init-authpanel root
  switch: (act) ->
    if !(act in <[signup login]>) => return
    p = if !lc.authpanel => ldcvmgr.getdom(\authpanel) else Promise.resolve(lc.authpanel)
    p.then (authpanel) ~>
      init-authpanel authpanel
      n = if authpanel.classList.contains \authpanel => authpanel else ld$.find(authpanel, '.authpanel', 0)
      n.classList
        ..remove \signup, \login
        ..add @act = act
      lc.form.check {now: true}
  social: (name) ->
    div = null
    auth.consent {timing: \signin}
      .then ~> @get!
      .then ({csrf-token}) ~>
        des = window.open '', 'social-login', 'height=640,width=560'
        div := ld$.create name: \div
        div.innerHTML = """
        <form target="social-login" action="#{auth.api}/u/auth/#name/" method="post">
          <input type="hidden" name="_csrf" value="#{csrf-token}"/>
        </form>"""
        document.body.appendChild div
        window.social-login = login = proxise(-> ld$.find(div, 'form', 0).submit!)
        login!
      .then ~> @fetch!
      .then ({user}) -> if !(user and user.key) => Promise.reject new ldError(1000)
      .then ->
        if !ldcvmgr.is-on(\authpanel) => return window.location.reload!
        lda.auth.hide \ok
      .then -> auth.consent {timing: \signin, bypass: true}
      .then -> auth.fire("auth.signin")
      .finally -> if div => ld$.remove div
      .catch error {ignore: [999 1000]}

  fb: -> @social \facebook
  google: -> @social \google
  logout: ->
    loader.on!
    ld$.fetch "#{auth.api}/u/logout", {method: \post}, {}
      .then -> auth.fetch {renew: true}
      .then -> ldcvmgr.toggle \logout
      .then -> loader.off!
      .catch -> ldcvmgr.toggle \error

  # ensure user is logged in. shorthand and for readbility for auth.get({authed:true})
  ensure: (opt = {}) -> @get(opt <<< {authed: true})
  # get global information.
  #  - authed: global must contains user object with key, else popup a login modal.
  #    reject if somehow error happens or login failed when authed = true
  get: (opt = {authed: false}) ->
    get!then (g) ->
      if opt.authed =>
        p = if !(g and g.{}user.key) => lda.auth.show(opt.tab, opt.info, opt) else Promise.resolve(g)
        p.then (g) ->
          if !(g and g.{}user.key) => return Promise.reject(new ldError(1000))
          lda.auth.hide \ok
          return g
      else return g

  userinfo: (user) ->
    promise = if user => Promise.resolve that else @get!then ({user}) -> return user
    promise.then (user = {}) ->
      plan = user.plan or {}
      return {} <<< user <<< {
        plan: plan
        authed: user.key > 0
        is-pro: !!/pro/.exec(plan.slug or '')
        is-blocked: !!user.{}config.blocked
      }

  # renew: set to true to force fetch data from server by ajax.
  fetch: (opt = {renew: true}) ->
    # if d/global response later then 1000ms, popup a loader
    is-on = false
    loader.on-later 1000 .then -> is-on := true

    # if it took too long to respond, just hint user about possibly server issue
    hint-fail = debounce(10000, ->
      loader.off!
      ldcvmgr.get('connection-timeout')
        .then -> loader.on!; debounce 10000
        .then -> auth.fetch!
    )!

    # if we don't force renew and there is a cache in cookie
    # otherwise we fetch data from server
    ret = if !opt.renew and /global=/.exec(document.cookie) =>
      document.cookie
        .split \;
        .map -> /^global=(.+)/.exec(it.trim!)
        .filter -> it
        .0
    else null
    promise = if ret => Promise.resolve JSON.parse(decodeURIComponent(ret.1))
    else ld$.fetch "#{auth.api}/global", {}, {type: \json}
    promise
      .then ~>
        hint-fail.cancel!
        loader.cancel!
        if is-on => loader.off!
        ld$.fetch.{}headers['X-CSRF-Token'] = it.csrfToken
        lc.global = it
        lc.global.location = (if ip-from-taiwan? => (if ip-from-taiwan it.ip => \tw else \other) else undefined)
        ret = global!
        get.resolve ret
        try
          ldc.fire \auth.change, ret
          cookie-consent.check!
          /* ga code { */
          if gtag? =>
            if !gtag.userid and ret.user and ret.user.key =>
              gtag(\set, {'user_id': gtag.userid = ret.user.key})
              # if set user_id -> either user just logged in, or user just open page.
              # force inited to false so used_id can be sent correctly.
              # this might lead to page view counted twice for each user login action.
              # also, since we put it here - event might not be sent when users browse pages
              # without auth.js. please keep this in mind.
              gtag.inited = false
            if !gtag.inited => gtag(\config, gtag.code, {anonymize_ip: true}); gtag.inited = true
          /* } ga code */
        catch e
          # error after data fetched. prompt, but still return global
          ldcvmgr.toggle("error"); console.log e
        return ret
      .catch ~>
        hint-fail.cancel!
        loader.cancel!
        ldcvmgr.toggle("server-down"); console.log it
        # since server is down and we have handled it here,
        # we simply return a promise that won't be resolved
        # to stop further progress of current code.
        new Promise (res, rej) ->
        loader.off!

  consent-time: {}
  consent: (opt = {}) ->
    type = opt.type or \tos
    cfg = ldsite.{}consent[type]
    cover = if cfg => cfg.cover or \consent else ''
    Promise.resolve!
      .then ->
        if !cfg => return
        auth.fetch!
          .then (g) ->
            if !opt.force and opt.timing and !(opt.timing in cfg.timing) => return
            time = g.user.{}config.{}consent[type] or auth.consent-time[type] or 0
            # > 10000 => sometimes we might have signin(consent) -> action(consent again) flow
            # so we expect two consent to be shown if they are not too close to each other.
            # additionally, we use auth.consent-time because
            # g.user.config.consent might be undefined due to the account is just created
            p = if !opt.bypass and
            ((opt.force and (Date.now! - time) > 10000) or !time or time < (cfg.time or 0)) =>
              if cfg.prompt => cfg.prompt!
              else
                ldcvmgr.getdom cover
                  .then (dom) ->
                    # TODO we should also make this configurable
                    if cfg.type == \link =>
                      iframe = ld$.find(dom, 'iframe', 0)
                      iframe.classList.remove \d-none
                      iframe.setAttribute \src, cfg.url
                    else
                      object = ld$.find(dom, 'object', 0)
                      object.classList.remove \d-none
                      if object => that.setAttribute(\data, cfg.url)
                      if ld$.find(dom, 'embed', 0) => that.setAttribute(\src, cfg.url)

                    ldcvmgr.get cover
            else Promise.resolve true

            p = p.then -> if !it => return Promise.reject new ldError(1018)
            # if user exists and consent time is empty, we should update the consent time
            # TODO: if consent is prompted before user sign in/up ?
            if g.user.key and !g.user.{}config.{}consent[type] =>
              p
                .then ->
                  auth.consent-time[type] = Date.now!
                  json = type: \consent, name: [type]
                  ld$.fetch("#{auth.api}/me/config", {method: \POST}, {json, type: \json})
                    .catch(->console.log ">", it) # user account not available yet. silent fail
                .then (ret = {}) ~> g.user.{}config <<< ret
            else p
  recaptcha: recaptcha

auth.fetch {renew: true}
  .then -> recaptcha.init!

action = do
  fb: -> auth.social \facebook
  google: -> auth.social \google
  logout: -> auth.logout!
  is-on: -> ldcvmgr.is-on \authpanel
  show: (n = \signup, info = \default, opt = {}) ->
    Promise.resolve(ldcvmgr.is-on \authpanel)
      .then -> if !it => auth.switch n
      .then -> if info => action.info info
      .then ->
        email = lc.form.getFields!email
        if opt.force-email =>
          email.setAttribute \readonly, true
          email.value = opt.force-email
          lc.form.check {n: \email, now: true}
        else email.removeAttribute \readonly
      .then -> ldcvmgr.get \authpanel
      .then -> if it => auth.fetch! # re-fetch only if get return sth.
  hide: (obj = null) -> ldcvmgr.set \authpanel, obj # default hide set with nothing to indicate a cancel.
  info: (name = \default) ->
    infos = ld$.find(lc.authpanel, '*[data-info]')
    hash = {}
    infos.map -> hash[it.getAttribute(\data-info)] = it
    infos.map -> it.classList.add \d-none
    if !hash[name] => name = \default
    hash[name].classList.remove \d-none
ldc.action action

auth
