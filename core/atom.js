var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(function() {
  var Game, atom, c, eventCode, _i, _ref, _ref1, _ref2;
  window.requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout((function() {
      return callback(1000 / 60);
    }), 1000 / 60);
  };
  window.cancelAnimationFrame = window.cancelAnimationFrame || window.webkitCancelAnimationFrame || window.mozCancelAnimationFrame || window.oCancelAnimationFrame || window.msCancelAnimationFrame || window.clearTimeout;
  atom = {};
  atom.input = {
    _bindings: {},
    _down: {},
    _pressed: {},
    _released: [],
    mouse: {
      x: 0,
      y: 0
    },
    bind: function(key, action) {
      return this._bindings[key] = action;
    },
    onkeydown: function(e) {
      var action;
      action = this._bindings[eventCode(e)];
      if (!action) {
        return;
      }
      if (!this._down[action]) {
        this._pressed[action] = true;
      }
      this._down[action] = true;
      e.stopPropagation();
      return e.preventDefault();
    },
    onkeyup: function(e) {
      var action;
      action = this._bindings[eventCode(e)];
      if (!action) {
        return;
      }
      this._released.push(action);
      e.stopPropagation();
      return e.preventDefault();
    },
    clearPressed: function() {
      var action, _i, _len, _ref;
      _ref = this._released;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        this._down[action] = false;
      }
      this._released = [];
      return this._pressed = {};
    },
    pressed: function(action) {
      return this._pressed[action];
    },
    down: function(action) {
      return this._down[action];
    },
    released: function(action) {
      return __indexOf.call(this._released, action) >= 0;
    },
    ontouchmove: function(e) {
      this.mouse.x = e.changedTouches[0].pageX;
      return this.mouse.y = e.changedTouches[0].pageY;
    },
    ontouchstart: function(e) {
      this.mouse.x = e.changedTouches[0].pageX;
      this.mouse.y = e.changedTouches[0].pageY;
      return this.onkeydown(e);
    },
    ontouchend: function(e) {
      this.mouse.x = e.changedTouches[0].pageX;
      this.mouse.y = e.changedTouches[0].pageY;
      return this.onkeyup(e);
    },
    onmousemove: function(e) {
      this.mouse.x = e.pageX;
      return this.mouse.y = e.pageY;
    },
    onmousedown: function(e) {
      return this.onkeydown(e);
    },
    onmouseup: function(e) {
      return this.onkeyup(e);
    },
    onmousewheel: function(e) {
      this.onkeydown(e);
      return this.onkeyup(e);
    },
    oncontextmenu: function(e) {
      if (this._bindings[atom.button.RIGHT]) {
        e.stopPropagation();
        return e.preventDefault();
      }
    }
  };
  document.onkeydown = atom.input.onkeydown.bind(atom.input);
  document.onkeyup = atom.input.onkeyup.bind(atom.input);
  document.onmouseup = atom.input.onmouseup.bind(atom.input);
  document.ontouchend = atom.input.ontouchend.bind(atom.input);
  document.ontouchcancel = atom.input.ontouchend.bind(atom.input);
  document.ontouchleave = atom.input.ontouchend.bind(atom.input);
  atom.touch = {
    TOUCHING: 1000
  };
  atom.button = {
    LEFT: -1,
    MIDDLE: -2,
    RIGHT: -3,
    WHEELDOWN: -4,
    WHEELUP: -5
  };
  atom.key = {
    TAB: 9,
    ENTER: 13,
    ESC: 27,
    SPACE: 32,
    LEFT_ARROW: 37,
    UP_ARROW: 38,
    RIGHT_ARROW: 39,
    DOWN_ARROW: 40
  };
  for (c = _i = 65; _i <= 90; c = ++_i) {
    atom.key[String.fromCharCode(c)] = c;
  }
  eventCode = function(e) {
    if (e.type === 'keydown' || e.type === 'keyup') {
      return e.keyCode;
    } else if (e.type === 'mousedown' || e.type === 'mouseup') {
      switch (e.button) {
        case 0:
          return atom.button.LEFT;
        case 1:
          return atom.button.MIDDLE;
        case 2:
          return atom.button.RIGHT;
      }
    } else if (e.type === 'mousewheel') {
      if (e.wheel > 0) {
        return atom.button.WHEELUP;
      } else {
        return atom.button.WHEELDOWN;
      }
    } else if (e.type === 'touchstart' || e.type === 'touchend' || e.type === 'touchcancel' || e.type === 'touchleave') {
      return atom.touch.TOUCHING;
    }
  };
  atom.canvas = document.getElementsByTagName('canvas')[0];
  atom.canvas.style.position = "absolute";
  atom.canvas.style.top = "0";
  atom.canvas.style.left = "0";
  atom.context = atom.canvas.getContext('2d');
  atom.context.clear = function() {
    return this.clearRect(0, 0, atom.width, atom.height);
  };
  atom.canvas.ontouchstart = atom.input.ontouchstart.bind(atom.input);
  atom.canvas.ontouchmove = atom.input.ontouchmove.bind(atom.input);
  atom.canvas.ontouchend = atom.input.ontouchend.bind(atom.input);
  atom.canvas.ontouchcancel = atom.input.ontouchend.bind(atom.input);
  atom.canvas.ontouchleave = atom.input.ontouchend.bind(atom.input);
  atom.canvas.onmousemove = atom.input.onmousemove.bind(atom.input);
  atom.canvas.onmousedown = atom.input.onmousedown.bind(atom.input);
  atom.canvas.onmouseup = atom.input.onmouseup.bind(atom.input);
  atom.canvas.onmousewheel = atom.input.onmousewheel.bind(atom.input);
  atom.canvas.oncontextmenu = atom.input.oncontextmenu.bind(atom.input);
  window.onresize = function(e) {
    atom.canvas.width = window.innerWidth;
    atom.canvas.height = window.innerHeight;
    atom.width = atom.canvas.width;
    return atom.height = atom.canvas.height;
  };
  window.onresize();
  Game = (function() {

    function Game() {}

    Game.prototype.update = function(dt) {};

    Game.prototype.draw = function() {};

    Game.prototype.run = function() {
      var s,
        _this = this;
      if (this.running) {
        return;
      }
      this.running = true;
      s = function() {
        _this.step();
        return setTimeout(function() {
          return _this.frameRequest = window.requestAnimationFrame(s);
        }, 30);
      };
      this.last_step = Date.now();
      return this.frameRequest = window.requestAnimationFrame(s);
    };

    Game.prototype.stop = function() {
      if (this.frameRequest) {
        cancelAnimationFrame(this.frameRequest);
      }
      this.frameRequest = null;
      return this.running = false;
    };

    Game.prototype.step = function() {
      var dt, now;
      now = Date.now();
      dt = (now - this.last_step) * 0.001;
      this.last_step = now;
      this.update(dt);
      this.draw();
      return atom.input.clearPressed();
    };

    return Game;

  })();
  atom.Game = Game;
  atom.gfx = {};
  atom.loadImage = function(url, callback) {
    var request;
    try {
      request = new Image();
      request.src = url;
      request.onload = function() {
        return typeof callback === "function" ? callback(null, request) : void 0;
      };
      return request.onerror = function() {
        return typeof callback === "function" ? callback(error) : void 0;
      };
    } catch (e) {
      return typeof callback === "function" ? callback(e.message) : void 0;
    }
  };
  atom.preloadImages = function(gfx, cb) {
    var name, toLoad, url, _results;
    toLoad = 0;
    _results = [];
    for (name in gfx) {
      url = gfx[name];
      toLoad++;
      _results.push((function(name, url) {
        return atom.loadImage("gfx/" + url, function(error, buffer) {
          if (error) {
            console.error(error);
          }
          if (buffer) {
            atom.gfx[name] = buffer;
          }
          if (!--toLoad) {
            return typeof cb === "function" ? cb() : void 0;
          }
        });
      })(name, url));
    }
    return _results;
  };

  // Patch to make game compatible with modern WebAudio API
  atom.audioContext = AudioContext? new AudioContext() : void 0;
  atom._mixer = (_ref = atom.audioContext) != null ? _ref.createGain() : void 0;
  if ((_ref1 = atom._mixer) != null) {
    _ref1.connect(atom.audioContext.destination);
  }
  if ((_ref2 = atom._mixer) != null) {
    _ref2._activeSounds = [];
  }
  atom.loadSound = function(url, callback) {
    var request;
    if (!atom.audioContext) {
      return typeof callback === "function" ? callback('No audio support') : void 0;
    }
    request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.responseType = 'arraybuffer';
    request.onload = function() {
      return atom.audioContext.decodeAudioData(request.response, function(buffer) {
        return typeof callback === "function" ? callback(null, buffer) : void 0;
      }, function(error) {
        return typeof callback === "function" ? callback(error) : void 0;
      });
    };
    try {
      return request.send();
    } catch (e) {
      return typeof callback === "function" ? callback(e.message) : void 0;
    }
  };
  atom.sfx = {};
  atom.preloadSounds = function(sfx, cb) {
    var name, toLoad, url, _results;
    if (!atom.audioContext) {
      return typeof cb === "function" ? cb('No audio support') : void 0;
    }
    toLoad = 0;
    _results = [];
    for (name in sfx) {
      url = sfx[name];
      toLoad++;
      _results.push((function(name, url) {
        return atom.loadSound("sfx/" + url, function(error, buffer) {
          if (error) {
            console.error(error);
          }
          if (buffer) {
            atom.sfx[name] = buffer;
          }
          if (!--toLoad) {
            return typeof cb === "function" ? cb() : void 0;
          }
        });
      })(name, url));
    }
    return _results;
  };
  atom.playSound = function(name, track, time) {
    var source;
    if (track == null) {
      track = true;
    }
    if (time == null) {
      time = 0;
    }
    if (!(atom.sfx[name] && atom.audioContext)) {
      return;
    }
    source = atom.audioContext.createBufferSource();
    source.buffer = atom.sfx[name];
    source.connect(atom._mixer);
    source.start(time);
    if (track) {
      atom._mixer._activeSounds.push(source);
    }
    return source;
  };
  atom.stopAllSounds = function() {
    var sound, _j, _len, _ref3;
    if (!atom.audioContext) {
      return;
    }
    _ref3 = atom._mixer._activeSounds;
    for (_j = 0, _len = _ref3.length; _j < _len; _j++) {
      sound = _ref3[_j];
      if (sound != null) {
        sound.stop(0);
      }
    }
    atom._mixer._activeSounds = [];
  };
  atom.setVolume = function(v) {
    var _ref3;
    return (_ref3 = atom._mixer) != null ? _ref3.gain.value = v : void 0;
  };
  return window.atom = atom;
});

// Generated by CoffeeScript 1.5.0-pre
