# error

Handler for frontend errors. use it in following pattern:

    ldc.register <[error]>, ({error}) ->
      do-something!
        .then -> ...
        .catch error(options)

where options is:

 - ignore: Array of codes defined in ldError to be ignored. optional
 - custom:
   - functions to process errors, hashed by error code defined in ldError. for example:
     do
       404: -> lda.ldcvmgr.toggle('error-404')
       1005: (e) -> alert('you got error'); console.log(e)
   
Default handlers:
  413: -> ldcvmgr.toggle('error-413')
  403: -> ldcvmgr.toggle('error-403')
  400: -> ldcvmgr.toggle('error-400')
  1004: -> ldcvmgr.toggle('assets-quota-exceeded')
  1005: -> ldcvmgr.toggle('csrftoken-mismatch')
  otherwise: -> ldcvmgr.toggle('error')

## APIs

 - is-on: check if `error` cover is on.

