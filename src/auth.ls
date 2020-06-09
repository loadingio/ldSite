({ldsite,ldcvmgr,loader,util,error,recaptcha}) <- ldc.register \auth, <[ldsite ldcvmgr loader util error recaptcha]>, _

#prevent global object been altered accidentally
global = -> if lc.global => JSON.parse(JSON.stringify lc.global) else null
[lc,el] = [{}, {}]

# cookie consent
consent = do
  dom: ld$.find document, '[ld-scope=cookie-consent]', 0
  val: util.cookie(\legal)
  clear: -> if @dom => ld$.remove(@dom); @dom = null
  check: ->
    ({user}) <~ auth.get!then _
    if user.{}config.legal and @dom => return @clear!
    if !(@val = util.cookie(\legal)) => return
    if ((user.{}config.legal) or !user.key) => return
    ld$.fetch("#{auth.api}/me/legal", {method: \POST}).then(~> user.{}config.legal = @val).catch(->)
  init: ->
    if !@val and @dom => @dom.classList.remove \d-none else return
    <~ ld$.find(@dom, '[ld=ok]', 0).addEventListener \click, _
    util.cookie \legal, (new Date!getTime!), new Date(Date.now() + 86400000 * 365 * 100).toGMTString()
    @clear!
    @check!
consent.init!

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
    recaptcha.get \signin
      .then (recaptcha) ->
        val = form.values!
        body = {} <<< val{email, passwd, displayname} <<< {config: {newsletter: val.newsletter}}
        # dunno why but some users have a literal tab in its password field, which cause problem here.
        # try to remove all of them.
        body.passwd = body.passwd.replace(/\t*$/,'')
        body.recaptcha = recaptcha
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
        auth.fire("auth.signin")
      .catch ->
        action.info \failed
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
    des = window.open '', 'social-login', 'height=640,width=560'
    div = ld$.create name: \div
    document.body.appendChild div
    @get!
      .then ({csrf-token}) ~>
        div.innerHTML = """
        <form target="social-login" action="#{auth.api}/u/auth/#name/" method="post">
          <input type="hidden" name="_csrf" value="#{csrf-token}"/>
        </form>"""
        window.social-login = login = proxise(-> ld$.find(div, 'form', 0).submit!)
        login!
      .then ~> @fetch!
      .then ({user}) -> if !(user and user.key) => Promise.reject new ldError(1000)
      .then ->
        if !ldcvmgr.is-on(\authpanel) => return window.location.reload!
        lda.auth.hide \ok
        auth.fire("auth.signin")
      .finally -> ld$.remove div
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
        p = if !(g and g.{}user.key) => lda.auth.show(opt.tab, opt.info) else Promise.resolve(g)
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
          consent.check!
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

auth.fetch {renew: true}
action = do
  fb: -> auth.social \facebook
  google: -> auth.social \google
  logout: -> auth.logout!
  is-on: -> ldcvmgr.is-on \authpanel
  show: (n = \signup, info = \default) ->
    Promise.resolve(ldcvmgr.is-on \authpanel)
      .then -> if !it => auth.switch n
      .then -> if info => action.info info
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
