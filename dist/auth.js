// Generated by LiveScript 1.3.1
var slice$ = [].slice;
ldc.register('auth', ['ldsite', 'ldcvmgr', 'loader', 'util', 'error'], function(arg$){
  var ldsite, ldcvmgr, loader, util, error, global, ref$, lc, el, recaptcha, cookieConsent, initAuthpanel, get, auth, action;
  ldsite = arg$.ldsite, ldcvmgr = arg$.ldcvmgr, loader = arg$.loader, util = arg$.util, error = arg$.error;
  global = function(){
    if (lc.global) {
      return JSON.parse(JSON.stringify(lc.global));
    } else {
      return null;
    }
  };
  ref$ = [{}, {}], lc = ref$[0], el = ref$[1];
  recaptcha = {
    lc: {
      ready: false,
      queue: [],
      tag: null,
      sitekey: null,
      global: null,
      enabled: true,
      inited: false
    },
    init: function(){
      var this$ = this;
      if (this.lc.inited) {
        return Promise.resolve();
      }
      return auth.get().then(function(g){
        var ref$;
        return ref$ = this$.lc, ref$.global = g, ref$.sitekey = (g.recaptcha || (g.recaptcha = {})).sitekey, ref$.enabled = (g.recaptcha || (g.recaptcha = {})).enabled, ref$;
      }).then(function(){
        var tag;
        if (!(this$.lc.enabled && this$.lc.sitekey) || this$.lc.tag) {
          return;
        }
        this$.lc.tag = tag = document.createElement("script");
        tag.onload = function(){
          return grecaptcha.ready(function(){
            this$.lc.ready = true;
            this$.lc.queue.map(function(it){
              return it.res();
            });
            return this$.lc.queue.splice(0);
          });
        };
        tag.setAttribute('type', "text/javascript");
        tag.setAttribute('src', "https://www.google.com/recaptcha/api.js?render=" + this$.lc.sitekey);
        return document.body.appendChild(tag);
      }).then(function(){
        return this$.lc.inited = true;
      });
    },
    get: function(action){
      var this$ = this;
      action == null && (action = 'generic');
      return this.init().then(function(){
        var p;
        if (!(this$.lc.sitekey && this$.lc.enabled)) {
          return Promise.resolve('');
        }
        p = this$.lc.ready
          ? Promise.resolve()
          : new Promise(function(res, rej){
            return this$.lc.queue.push({
              res: res,
              rej: rej
            });
          });
        return p.then(function(){
          return grecaptcha.execute(this$.lc.sitekey, {
            action: action
          });
        }).then(function(token){
          return token;
        });
      });
    }
  };
  cookieConsent = {
    dom: ld$.find(document, '[ld-scope=cookie-consent]', 0),
    val: util.cookie('consent.cookie'),
    clear: function(){
      if (this.dom) {
        ld$.remove(this.dom);
        return this.dom = null;
      }
    },
    check: function(){
      var this$ = this;
      return auth.get().then(function(arg$){
        var user, ref$;
        user = arg$.user;
        if (((ref$ = user.config || (user.config = {})).consent || (ref$.consent = {})).cookie && this$.dom) {
          return this$.clear();
        }
        if (!(this$.val = util.cookie('consent.cookie'))) {
          return;
        }
        if (((ref$ = user.config || (user.config = {})).consent || (ref$.consent = {})).cookie || !user.key) {
          return;
        }
        return ld$.fetch(auth.api + "/me/config", {
          method: 'POST'
        }, {
          json: {
            type: 'consent',
            name: ['cookie']
          }
        }).then(function(ret){
          var ref$;
          ret == null && (ret = {});
          import$(user.config || (user.config = {}), ret);
          return util.cookie('consent.cookie', ((ref$ = ret.config || (ret.config = {})).consent || (ref$.consent = {})).cookie || Date.now(), new Date(Date.now() + 86400000 * 365 * 100).toGMTString());
        })['catch'](function(){});
      });
    },
    init: function(){
      var this$ = this;
      if (!this.val && this.dom) {
        this.dom.classList.remove('d-none');
      } else {
        return;
      }
      return ld$.find(this.dom, '[ld=ok]', 0).addEventListener('click', function(){
        this$.clear();
        return this$.check();
      });
    }
  };
  cookieConsent.init();
  initAuthpanel = function(dom){
    var authpanel, that, acts, form, ldld, submit;
    authpanel = lc.authpanel = (that = dom)
      ? that
      : ld$.find(document, '.authpanel', 0);
    if (!lc.authpanel || lc.inited) {
      return;
    }
    lc.inited = true;
    acts = ld$.find(authpanel, '[data-action]');
    authpanel.addEventListener('click', function(e){
      var n, act;
      if (!e || !(n = e.target) || !e.target.getAttribute) {
        return;
      }
      act = e.target.getAttribute('data-action');
      return auth['switch'](act);
    });
    lc.form = form = new ldForm({
      names: function(){
        return ['email', 'passwd', 'displayname'];
      },
      afterCheck: function(s, f){
        if (s.email !== 1 && !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(f.email.value)) {
          s.email = 2;
        }
        if (s.passwd !== 1) {
          if (auth.act !== 'login' && (f.passwd.value + "").length < 8) {
            s.passwd = 2;
          } else {
            s.passwd = !f.passwd.value ? 1 : 0;
          }
        }
        if (auth.act === 'login') {
          return s.displayname = 0;
        } else {
          return s.displayname = !f.displayname.value
            ? 1
            : !!f.displayname.value ? 0 : 2;
        }
      },
      root: authpanel
    });
    el.submit = ld$.find(authpanel, '[data-action=submit]', 0);
    ldld = new ldLoader({
      root: el.submit
    });
    form.on('readystatechange', function(it){
      return el.submit.classList.toggle('disabled', !it);
    });
    form.field('passwd').addEventListener('keyup', function(e){
      if (e.keyCode === 13) {
        return form.check({
          now: true
        }).then(function(){
          return submit();
        });
      }
    });
    el.submit.addEventListener('click', function(){
      return submit();
    });
    return submit = function(){
      var val, body, ref$, ref1$;
      if (!form.ready()) {
        return;
      }
      ldld.on();
      val = form.values();
      body = (ref$ = (ref1$ = {}, ref1$.email = val.email, ref1$.passwd = val.passwd, ref1$.displayname = val.displayname, ref1$), ref$.config = {
        newsletter: val.newsletter
      }, ref$);
      body.passwd = body.passwd.replace(/\t*$/, '');
      return recaptcha.get('signin').then(function(recaptcha){
        return body.recaptcha = recaptcha;
      }).then(function(){
        return auth.consent({
          timing: 'signin'
        });
      }).then(function(){
        return ld$.fetch(auth.act === 'login'
          ? auth.api + "/u/login"
          : auth.api + "/u/signup", {
          method: 'POST',
          body: JSON.stringify(body),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8'
          }
        }, {
          type: 'text'
        });
      }).then(function(){
        return auth.fetch();
      }).then(function(){
        return auth.get();
      }).then(function(g){
        action.info('default');
        if (g.user) {
          lda.auth.hide('ok');
        }
        form.reset();
        return ldld.off();
      }).then(function(){
        return auth.consent({
          timing: 'signin',
          bypass: true
        });
      }).then(function(){
        return auth.fire("auth.signin");
      })['catch'](function(){
        if (auth.act === 'signup') {
          action.info('signup-failed');
        } else {
          action.info('failed');
        }
        form.fields.passwd.value = null;
        form.check({
          n: 'passwd',
          now: true
        });
        return ldld.off();
      });
    };
  };
  get = proxise(function(){
    if (lc.global) {
      return Promise.resolve(lc.global);
    }
  });
  auth = {
    api: (ldsite ? ldsite.api : 'd').replace(/\/$/, ''),
    init: function(opt){
      var root;
      opt == null && (opt = {});
      if (!opt.root) {
        return;
      }
      root = typeof opt.root === 'string'
        ? document.querySelector(opt.root)
        : opt.root;
      return initAuthpanel(root);
    },
    evtHandler: {},
    on: function(n, cb){
      var ref$;
      return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
    },
    fire: function(n){
      var v, i$, ref$, len$, cb, results$ = [];
      v = slice$.call(arguments, 1);
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    },
    manuallyInit: function(opt){
      var root;
      opt == null && (opt = {});
      if (!opt.root) {
        return;
      }
      root = typeof opt.root === 'string'
        ? document.querySelector(opt.root)
        : opt.root;
      return initAuthpanel(root);
    },
    'switch': function(act){
      var p, this$ = this;
      if (!(act === 'signup' || act === 'login')) {
        return;
      }
      p = !lc.authpanel
        ? ldcvmgr.getdom('authpanel')
        : Promise.resolve(lc.authpanel);
      return p.then(function(authpanel){
        var n, x$;
        initAuthpanel(authpanel);
        n = authpanel.classList.contains('authpanel')
          ? authpanel
          : ld$.find(authpanel, '.authpanel', 0);
        x$ = n.classList;
        x$.remove('signup', 'login');
        x$.add(this$.act = act);
        return lc.form.check({
          now: true
        });
      });
    },
    social: function(name){
      var div, this$ = this;
      div = null;
      return auth.consent({
        timing: 'signin'
      }).then(function(){
        return this$.get();
      }).then(function(arg$){
        var csrfToken, des, login;
        csrfToken = arg$.csrfToken;
        des = window.open('', 'social-login', 'height=640,width=560');
        div = ld$.create({
          name: 'div'
        });
        div.innerHTML = "<form target=\"social-login\" action=\"" + auth.api + "/u/auth/" + name + "/\" method=\"post\">\n  <input type=\"hidden\" name=\"_csrf\" value=\"" + csrfToken + "\"/>\n</form>";
        document.body.appendChild(div);
        window.socialLogin = login = proxise(function(){
          return ld$.find(div, 'form', 0).submit();
        });
        return login();
      }).then(function(){
        return this$.fetch();
      }).then(function(arg$){
        var user;
        user = arg$.user;
        if (!(user && user.key)) {
          return Promise.reject(new ldError(1000));
        }
      }).then(function(){
        if (!ldcvmgr.isOn('authpanel')) {
          return window.location.reload();
        }
        return lda.auth.hide('ok');
      }).then(function(){
        return auth.consent({
          timing: 'signin',
          bypass: true
        });
      }).then(function(){
        return auth.fire("auth.signin");
      })['finally'](function(){
        if (div) {
          return ld$.remove(div);
        }
      })['catch'](error({
        ignore: [999, 1000]
      }));
    },
    fb: function(){
      return this.social('facebook');
    },
    google: function(){
      return this.social('google');
    },
    logout: function(){
      loader.on();
      return ld$.fetch(auth.api + "/u/logout", {
        method: 'post'
      }, {}).then(function(){
        return auth.fetch({
          renew: true
        });
      }).then(function(){
        return ldcvmgr.toggle('logout');
      }).then(function(){
        return loader.off();
      })['catch'](function(){
        return ldcvmgr.toggle('error');
      });
    },
    ensure: function(opt){
      opt == null && (opt = {});
      return this.get((opt.authed = true, opt));
    },
    get: function(opt){
      opt == null && (opt = {
        authed: false
      });
      return get().then(function(g){
        var p;
        if (opt.authed) {
          p = !(g && (g.user || (g.user = {})).key)
            ? lda.auth.show(opt.tab, opt.info, opt)
            : Promise.resolve(g);
          return p.then(function(g){
            if (!(g && (g.user || (g.user = {})).key)) {
              return Promise.reject(new ldError(1000));
            }
            lda.auth.hide('ok');
            return g;
          });
        } else {
          return g;
        }
      });
    },
    userinfo: function(user){
      var promise, that;
      promise = (that = user)
        ? Promise.resolve(that)
        : this.get().then(function(arg$){
          var user;
          user = arg$.user;
          return user;
        });
      return promise.then(function(user){
        var plan, ref$;
        user == null && (user = {});
        plan = user.plan || {};
        return ref$ = import$({}, user), ref$.plan = plan, ref$.authed = user.key > 0, ref$.isPro = !!/pro/.exec(plan.slug || ''), ref$.isBlocked = !!(user.config || (user.config = {})).blocked, ref$;
      });
    },
    fetch: function(opt){
      var isOn, hintFail, ret, promise, this$ = this;
      opt == null && (opt = {
        renew: true
      });
      isOn = false;
      loader.onLater(1000).then(function(){
        return isOn = true;
      });
      hintFail = debounce(10000, function(){
        loader.off();
        return ldcvmgr.get('connection-timeout').then(function(){
          loader.on();
          return debounce(10000);
        }).then(function(){
          return auth.fetch();
        });
      })();
      ret = !opt.renew && /global=/.exec(document.cookie) ? document.cookie.split(';').map(function(it){
        return /^global=(.+)/.exec(it.trim());
      }).filter(function(it){
        return it;
      })[0] : null;
      promise = ret
        ? Promise.resolve(JSON.parse(decodeURIComponent(ret[1])))
        : ld$.fetch(auth.api + "/global", {}, {
          type: 'json'
        });
      return promise.then(function(it){
        var ref$, ret, e;
        hintFail.cancel();
        loader.cancel();
        if (isOn) {
          loader.off();
        }
        ((ref$ = ld$.fetch).headers || (ref$.headers = {}))['X-CSRF-Token'] = it.csrfToken;
        lc.global = it;
        lc.global.location = typeof ipFromTaiwan != 'undefined' && ipFromTaiwan !== null ? ipFromTaiwan(it.ip) ? 'tw' : 'other' : undefined;
        ret = global();
        get.resolve(ret);
        try {
          ldc.fire('auth.change', ret);
          cookieConsent.check();
          /* ga code { */
          if (typeof gtag != 'undefined' && gtag !== null) {
            if (!gtag.userid && ret.user && ret.user.key) {
              gtag('set', {
                'user_id': gtag.userid = ret.user.key
              });
              gtag.inited = false;
            }
            if (!gtag.inited) {
              gtag('config', gtag.code, {
                anonymize_ip: true
              });
              gtag.inited = true;
            }
          }
          /* } ga code */
        } catch (e$) {
          e = e$;
          ldcvmgr.toggle("error");
          console.log(e);
        }
        return ret;
      })['catch'](function(it){
        hintFail.cancel();
        loader.cancel();
        ldcvmgr.toggle("server-down");
        console.log(it);
        new Promise(function(res, rej){});
        return loader.off();
      });
    },
    consentTime: {},
    consent: function(opt){
      var type, cfg, cover;
      opt == null && (opt = {});
      type = opt.type || 'tos';
      cfg = (ldsite.consent || (ldsite.consent = {}))[type];
      cover = cfg ? cfg.cover || 'consent' : '';
      return Promise.resolve().then(function(){
        if (!cfg) {
          return;
        }
        return auth.fetch().then(function(g){
          var time, ref$, ref1$, p, this$ = this;
          if (!opt.force && opt.timing && !in$(opt.timing, cfg.timing)) {
            return;
          }
          time = ((ref$ = (ref1$ = g.user).config || (ref1$.config = {})).consent || (ref$.consent = {}))[type] || auth.consentTime[type] || 0;
          p = !opt.bypass && ((opt.force && Date.now() - time > 10000) || !time || time < (cfg.time || 0))
            ? cfg.prompt
              ? cfg.prompt()
              : ldcvmgr.getdom(cover).then(function(dom){
                var iframe, object, that;
                if (cfg.type === 'link') {
                  iframe = ld$.find(dom, 'iframe', 0);
                  iframe.classList.remove('d-none');
                  iframe.setAttribute('src', cfg.url);
                } else {
                  object = ld$.find(dom, 'object', 0);
                  object.classList.remove('d-none');
                  if (that = object) {
                    that.setAttribute('data', cfg.url);
                  }
                  if (that = ld$.find(dom, 'embed', 0)) {
                    that.setAttribute('src', cfg.url);
                  }
                }
                return ldcvmgr.get(cover);
              })
            : Promise.resolve(true);
          p = p.then(function(it){
            if (!it) {
              return Promise.reject(new ldError(1018));
            }
          });
          if (g.user.key && !((ref$ = (ref1$ = g.user).config || (ref1$.config = {})).consent || (ref$.consent = {}))[type]) {
            return p.then(function(){
              var json;
              auth.consentTime[type] = Date.now();
              json = {
                type: 'consent',
                name: [type]
              };
              return ld$.fetch(auth.api + "/me/config", {
                method: 'POST'
              }, {
                json: json,
                type: 'json'
              })['catch'](function(it){
                return console.log(">", it);
              });
            }).then(function(ret){
              var ref$;
              ret == null && (ret = {});
              return import$((ref$ = g.user).config || (ref$.config = {}), ret);
            });
          } else {
            return p;
          }
        });
      });
    },
    recaptcha: recaptcha
  };
  auth.fetch({
    renew: true
  }).then(function(){
    return recaptcha.init();
  });
  action = {
    fb: function(){
      return auth.social('facebook');
    },
    google: function(){
      return auth.social('google');
    },
    logout: function(){
      return auth.logout();
    },
    isOn: function(){
      return ldcvmgr.isOn('authpanel');
    },
    show: function(n, info, opt){
      n == null && (n = 'signup');
      info == null && (info = 'default');
      opt == null && (opt = {});
      return Promise.resolve(ldcvmgr.isOn('authpanel')).then(function(it){
        if (!it) {
          return auth['switch'](n);
        }
      }).then(function(){
        if (info) {
          return action.info(info);
        }
      }).then(function(){
        var email;
        email = lc.form.getFields().email;
        if (opt.forceEmail) {
          email.setAttribute('readonly', true);
          email.value = opt.forceEmail;
          return lc.form.check({
            n: 'email',
            now: true
          });
        } else {
          return email.removeAttribute('readonly');
        }
      }).then(function(){
        return ldcvmgr.get('authpanel');
      }).then(function(it){
        if (it) {
          return auth.fetch();
        }
      });
    },
    hide: function(obj){
      obj == null && (obj = null);
      return ldcvmgr.set('authpanel', obj);
    },
    info: function(name){
      var infos, hash;
      name == null && (name = 'default');
      infos = ld$.find(lc.authpanel, '*[data-info]');
      hash = {};
      infos.map(function(it){
        return hash[it.getAttribute('data-info')] = it;
      });
      infos.map(function(it){
        return it.classList.add('d-none');
      });
      if (!hash[name]) {
        name = 'default';
      }
      return hash[name].classList.remove('d-none');
    }
  };
  ldc.action(action);
  return auth;
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}
