// Generated by LiveScript 1.3.1
(function(){
  return ldc.register("recaptcha", ['auth'], function(arg$){
    var auth, lc, ret;
    auth = arg$.auth;
    lc = {
      ready: false,
      queue: [],
      tag: null,
      sitekey: null,
      global: null,
      enabled: true
    };
    grecaptcha.ready(function(){
      lc.ready = true;
      lc.queue.map(function(it){
        return it.res();
      });
      return lc.queue.splice(0);
    });
    return ret = {
      get: function(action){
        action == null && (action = 'generic');
        return Promise.resolve().then(function(){
          if (lc.global) {
            return;
          }
          return auth.get().then(function(g){
            return lc.global = g, lc.sitekey = (g.recaptcha || (g.recaptcha = {})).sitekey, lc.enabled = (g.recaptcha || (g.recaptcha = {})).enabled, lc;
          });
        }).then(function(){
          var p;
          if (!lc.sitekey || !lc.enabled) {
            return Promise.resolve('');
          }
          p = !(typeof grecaptcha != 'undefined' && grecaptcha !== null)
            ? new Promise(function(res, rej){
              var tag;
              if (!lc.tag) {
                lc.tag = tag = document.createElement("script");
                tag.setAttribute('type', "text/javascript");
                tag.setAttribute('src', "https://www.google.com/recaptcha/api.js?render=" + lc.sitekey);
                document.body.appendChild(tag);
              }
              return !lc.ready
                ? lc.queue.push({
                  res: res,
                  rej: rej
                })
                : res();
            })
            : Promise.resolve();
          return p.then(function(){
            return grecaptcha.execute(lc.sitekey, {
              action: action
            });
          }).then(function(token){
            return token;
          });
        });
      }
    };
  });
})();
