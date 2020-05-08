# put every core you will need here to initialize them
(->
  ldc.register \sample-site, <[auth ldcvmgr navtop]>, ({auth, ldcvmgr, navtop}) ->
  ldc.app \sample-site
)!
