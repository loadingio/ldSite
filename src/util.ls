(->
  ldc.register \util, <[]>, ->
    local = {}
    return do
      cookie: (k,v,expire) ->
        if v => return document.cookie = "#k=#v;path=/" + (if expire => ";expires=#expire" else "")
        hash = {}
        (document.cookie or '')
          .split(\;)
          .map -> it.split(\=).map(->it.trim!)
          .map -> hash[decodeURIComponent(it.0)] = decodeURIComponent(it.1)
        return hash[k]
      parse-querystring: (key) ->
        if !(hash = local.querystring) =>
          local.querystring = hash = {}
          (window.location.search or "")
            .replace(/^\?/,'')
            .split(\&)
            .map -> decodeURIComponent(it).split('=')
            .map -> hash[it.0] = it.1
        return if key => hash[key] else hash

)!
