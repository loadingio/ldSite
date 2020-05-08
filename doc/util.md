# util

## APIs

 * cookie(key,value,expire)
   - set cookie `key` with `value` and expire date `expire`, if value is present.
   - get cookie `key` if value is omitted.
 * parseQuerystring(key)
   - get value for `key` from query string.
   - return a hash for all key value pairs if key is omitted.
