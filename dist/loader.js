// Generated by LiveScript 1.3.1
(function(){
  return ldc.register('loader', [], function(){
    var ldld, ref$, th, ph;
    ldld = new ldLoader({
      className: 'ldld full',
      autoZ: true,
      atomic: false
    });
    ref$ = [null, {}], th = ref$[0], ph = ref$[1];
    return {
      on: function(){
        return ldld.on();
      },
      off: function(){
        return ldld.off();
      },
      onLater: function(ms){
        var this$ = this;
        ms == null && (ms = 500);
        return new Promise(function(res, rej){
          this$.cancel();
          ph.res = res;
          ph.rej = rej;
          return th = setTimeout(function(){
            ldld.on();
            ph.res(true);
            return ph.res = null;
          }, ms);
        });
      },
      cancel: function(){
        clearTimeout(th);
        if (ph.res) {
          ph.res(false);
        }
        return ph.res = null;
      }
    };
  });
})();
