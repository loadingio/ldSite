(->
  # full screen loader.
  #  - on/off as ldLoader
  #  - on-later - on after xxms.
  #  - cancel - cancel and turn off loader if it's been on-later.
  <- ldc.register \loader, <[]>, _
  ldld = new ldLoader className: 'ldld full', auto-z: true, atomic: false
  h = null
  return do
    on: -> ldld.on!
    off: -> ldld.off!
    on-later: (ms = 500) -> @cancel!; h := setTimeout (-> ldld.on! ), ms
    cancel: -> clearTimeout h; ldld.off!
)!
