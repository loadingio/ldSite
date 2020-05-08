(->
  ldc.register \navtop, <[auth]>, ({auth}) ->
    lc = signed: false, pro: false, user: {}
    nav-check = (g) ->
      lc <<< signed: !!g.{}user.key, pro: g.{}user.plan, user: g.{}user
      view.render!

    navbar = document.querySelector '#nav-top nav'
    if !navbar => return

    view = new ldView root: ld$.find(navbar, '[ld-scope]',0), handler: do
      displayname: ({node}) -> node.innerText = lc.user.displayname or \You
      login: ({node}) -> node.classList.toggle \d-none, lc.signed
      signup: ({node}) -> node.classList.toggle \d-none, lc.signed
      "upgrade-now": ({node}) -> node.classList.toggle \d-none, lc.pro
      profile:  ({node}) -> node.classList.toggle \d-none, !lc.signed
      avatar: ({node}) -> if lc.signed => node.style.backgroundImage = "url(/s/avatar/#{lc.user.key}.png)"
      plan: ({node}) ->
        node.innerText = if lc.pro => \PRO else \FREE
        node.classList.toggle \badge-primary, lc.pro
        node.classList.toggle \badge-secondary, !lc.pro
    ldc.on \auth.change, nav-check
    auth.get!then nav-check

    # navtop change style if data-transition and data-transition-target is defined.
    # data-transition = "class1 class2 ...;class1 class2 ..." for before and after transition classs.
    # data-transition-target: node to monitor for visibility and thus reflect the whether state should be change.
    # these can be set by ctrl.navtop.transition and ctrl.navtop.transitionTarget config.
    dotst = (navbar.getAttribute(\data-transition) or "").split(';').map(->it.split(' ').filter(->it))
    tst-tgt = ld$.find document, navbar.getAttribute(\data-transition-target), 0
    if !(dotst.length and tst-tgt) => return
    (new IntersectionObserver (->
      if !(n = it.0) => return
      dotst.0.map (c) -> navbar.classList.toggle c, n.isIntersecting
      dotst.1.map (c) -> navbar.classList.toggle c, !n.isIntersecting
    ), {threshold: 0.1}).observe tst-tgt

)!
