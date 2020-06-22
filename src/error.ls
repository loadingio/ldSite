(->
  ldc.register \error, <[ldcvmgr]>, ({ldcvmgr}) ->
    http-code = do
      413: -> ldcvmgr.toggle('error-413')
      404: -> ldcvmgr.toggle('error-404')
      403: -> ldcvmgr.toggle('error-403')
      400: -> ldcvmgr.toggle('error-400')
    ld-code = do
      1004: -> ldcvmgr.toggle('assets-quota-exceeded')
      1005: -> ldcvmgr.toggle('csrftoken-mismatch')
      1016: -> ldcvmgr.toggle('not-yet-available')
      1018: -> ldcvmgr.toggle('consent-required')
    ret = (opt = {}) -> (e) ->
      if e and e.json and e.json.name == \ldError =>
        code = e.json.id or e.json.code
      code = if e => +(code or e.id or e.code) else null
      if code and !isNaN(code) =>
        if (code in (opt.ignore or [999])) => return
        if (opt.custom and opt.custom[code]) => return opt.custom[code] e
        if ld-code[code] => return ld-code[code] e
        if http-code[code] => return http-code[code] e
      ldcvmgr.toggle('error'); console.log e
    ret.is-on = -> ldcvmgr.is-on \error
    return ret
)!
