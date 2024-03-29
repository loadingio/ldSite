// Generated by LiveScript 1.3.1
(function(){
  return ldc.register('util', [], function(){
    var local;
    local = {};
    return {
      cookie: function(k, v, expire){
        var hash;
        if (v) {
          return document.cookie = (k + "=" + v + ";path=/") + (expire ? ";expires=" + expire : "");
        }
        hash = {};
        (document.cookie || '').split(';').map(function(it){
          return it.split('=').map(function(it){
            return it.trim();
          });
        }).map(function(it){
          return hash[decodeURIComponent(it[0])] = decodeURIComponent(it[1]);
        });
        return hash[k];
      },
      parseQuerystring: function(key){
        var hash;
        if (!(hash = local.querystring)) {
          local.querystring = hash = {};
          (window.location.search || "").replace(/^\?/, '').split('&').map(function(it){
            return decodeURIComponent(it).split('=');
          }).map(function(it){
            return hash[it[0]] = it[1];
          });
        }
        return key ? hash[key] : hash;
      }
    };
  });
})();
