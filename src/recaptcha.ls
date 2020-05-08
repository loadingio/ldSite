(->
  ldc.register "recaptcha", [], ->
    lc = ready: false, queue: []
    if !(grecaptcha?) => return get: -> Promise.resolve('')
    grecaptcha.ready ->
      lc.ready = true
      lc.queue.map -> it.res!
      lc.queue = []
    return do
      get: (action = \generic) ->
        p = new Promise (res, rej) -> if !lc.ready => return lc.queue.push {res, rej} else res!
        p
          .then -> grecaptcha.execute('6LdGndkUAAAAANa4WAMz-aJiih01CvNuMBQP0bzF', {action})
          .then (token) -> return token
)!
