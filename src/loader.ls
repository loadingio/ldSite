(->
  # full screen loader.
  #  - on/off as ldLoader
  #  - on-later - on after xxms.
  #  - cancel - cancel and turn off loader if it's been on-later.
  <- ldc.register \loader, <[]>, _
  ldld = new ldLoader className: 'ldld full', auto-z: true, atomic: false
  # timeout handler and promise handler
  [th, ph] = [null, {}]
  return do
    on: -> ldld.on!
    off: -> ldld.off!
    # promise resolve true if loader is set on by this. otherwise resolve false.
    on-later: (ms = 500) -> new Promise (res, rej) ~>
      @cancel!
      ph <<< {res, rej}
      th := setTimeout (->
        ldld.on!
        ph.res true
        ph.res = null
      ), ms
    cancel: ->
      clearTimeout th
      if ph.res => ph.res false
      ph.res = null
)!
