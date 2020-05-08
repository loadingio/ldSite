(->
  <- ldc.register \ldcvmgr, [], _
  error = (n = '', e = {}) ->
    if n == \error => alert "something is wrong; please reload and try again"
    else ldcvmgr.toggle \error
    console.log(e.message or e)

  ldcvmgr = do
    loader: new ldLoader className: "ldld full", auto-z: true
    covers: covers = {}
    prepare: (n) ->
      if @covers[n] => return Promise.resolve!
      @loader.on 1000
      fetch "/modules/cover/#n.html"
        .then (v) ~>
          if !(v and v.ok) => throw new Error("modal '#{if !n => '<no-name>' else n}' load failed.")
          v.text!
        .then ~>
          document.body.appendChild (div = document.createElement("div"))
          div.innerHTML = it
          ld$.find(div,\script).map ->
            script = ld$.create name: \script, attr: type: \text/javascript
            script.text = it.textContent
            it.parentNode.replaceChild script, it
          root = div.querySelector('.ldcv')
          @covers[n] = new ldCover root: root, lock: root.getAttribute(\data-lock) == \true
          debounce 1
        .finally ~> @loader.cancel!
        .catch ~> throw it
    purge: (n) -> if n? => delete @covers[n] else @covers = {}
    toggle: (n, v, p) ->
      @prepare(n)
        .then ~> @covers[n].toggle v
        .then ~> ldc.fire "ldcvmgr.#n.#{if @covers[n].is-on! => \on else \off}", {node: @covers[n], param: p}
        .catch -> error(n,it)

    getcover: (n) -> @prepare n .then ~> @covers[n]
    getdom: (n) -> @prepare n .then ~> @covers[n].root
    is-on: (n) -> @covers[n] and @covers[n].is-on!
    set: (n, p) ->
      @prepare(n).then ~> @covers[n].set p
    get: (n, p) ->
      @prepare(n)
        .then ~> ldc.fire "ldcvmgr.#n.on", {node: @covers[n], param: p}
        .then ~> @covers[n].get!
        .catch -> error(n,it)

  Array.from(document.querySelectorAll('.ldcvmgr')).map (n) ~>
    # only keep the first, named ldcvmgr.
    if !(id = n.getAttribute(\data-name)) or covers[id] => return
    covers[id] = new ldCover({root: n, lock: n.getAttribute(\data-lock) == \true})
  Array.from(document.querySelectorAll('[data-ldcv-toggle]')).map (n) ~>
    if !(id = n.getAttribute(\data-ldcv-toggle)) => return
    n.addEventListener \click, ~> @toggle id
  ldc.action do
    toggle: (n,v,p) -> ldcvmgr.toggle n,v,p
    purge: (n) -> ldcvmgr.purge n
    get: (n,p) -> ldcvmgr.get n,p
  return ldcvmgr
)!
