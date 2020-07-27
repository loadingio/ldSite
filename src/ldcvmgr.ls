(->
  ({ldsite}) <- ldc.register \ldcvmgr, <[ldsite]>, _
  cover = (if ldsite and ldsite.ldcvmgr-root => that else "/modules/cover").replace(/\/$/,'')

  error = (n = '', e = {}) ->
    if n == \error => alert "something is wrong; please reload and try again"
    else ldcvmgr.toggle \error
    console.log(e.message or e)

  ldcvmgr = do
    loader: new ldLoader className: "ldld full", auto-z: true
    covers: covers = {}
    workers: {}
    prepare-proxy: proxise (n) ->
    prepare: (n) ->
      if @covers[n] => return Promise.resolve!
      if @workers[n] => return @prepare-proxy(n)
      @loader.on 1000
      p = if document.querySelector(".ldcvmgr[data-name=#n]") => Promise.resolve(that)
      else
        @workers[n] = fetch "#cover/#n.html"
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
      p
        .then (root) ~>
          @covers[n] = new ldCover root: root, lock: root.getAttribute(\data-lock) == \true
          ldcvmgr.prepare-proxy.resolve!
          delete @workers[n]
          debounce 1
        .finally ~> @loader.cancel false
        .catch ~> throw it
    purge: (n) -> if n? => delete @covers[n] else @covers = {}
    lock: (n, p) ->
      @prepare(n)
        .then ~> @covers[n].lock!
        .then ~> @covers[n].toggle true
        .catch -> error(n,it)
    toggle: (n, v, p) ->
      @prepare(n)
        .then ~> @covers[n].toggle v
        .then ~> ldc.fire "ldcvmgr.#n.#{if @covers[n].is-on! => \on else \off}", {node: @covers[n], param: p}
        .catch -> error(n,it)

    getcover: (n) -> @prepare n .then ~> @covers[n]
    getdom: (n) -> @prepare n .then ~> @covers[n].root
    is-on: (n) -> @covers[n] and @covers[n].is-on!
    set: (n, p) -> @prepare(n).then ~> @covers[n].set p
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
    lock: (n,p) -> ldcvmgr.lock n,p
  return ldcvmgr
)!
