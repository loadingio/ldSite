// Generated by LiveScript 1.3.1
(function(){
  return ldc.register('loader', [], function(){
    var ldld, h;
    ldld = new ldLoader({
      className: 'ldld full',
      autoZ: true,
      atomic: false
    });
    h = null;
    return {
      on: function(){
        return ldld.on();
      },
      off: function(){
        return ldld.off();
      },
      onLater: function(ms){
        ms == null && (ms = 500);
        this.cancel();
        return h = setTimeout(function(){
          return ldld.on();
        }, ms);
      },
      cancel: function(){
        return clearTimeout(h);
      }
    };
  });
})();
