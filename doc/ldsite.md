# ldsite 

`ldsite` is a core that you can setup to configure other cores. It's by default not provided and should be prepared by users, if needed.

A typical `ldsite` core is like:

    ldc.register \ldsite, <[]>, -> return config = {}

where config can contain:

 * `api`: api root for accessing data with server. it's default "/d/" and can be overwritten to "/api/" or something like this, if necessary.
