var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['core/placetiles'], function(placeTiles) {
  var Button, CELLSIZE, Kulami, MoveTile;
  CELLSIZE = 32;
  MoveTile = (function() {

    MoveTile.prototype.BORDERSIZE = 4;

    MoveTile.prototype.BORDERSIZE_ = 0.25;

    MoveTile.prototype.CELLSIZE = CELLSIZE;

    MoveTile.prototype.size = null;

    MoveTile.prototype.x = 0;

    MoveTile.prototype.y = 0;

    MoveTile.prototype.w = 1;

    MoveTile.prototype.h = 1;

    MoveTile.prototype.invalidPlacement = true;

    MoveTile.prototype.transposeOrientation = function() {
      var _h, _ref, _w;
      _ref = [this.w, this.h], _w = _ref[0], _h = _ref[1];
      this.w = _h;
      return this.h = _w;
    };

    MoveTile.prototype.containsPoint = function(x, y) {
      return ((this.x < x && x < this.x + this.CELLSIZE * this.w)) && ((this.y < y && y < this.y + this.CELLSIZE * this.h));
    };

    MoveTile.prototype.draw = function() {
      var ac, cx, cy, h, i, j, w, x, y, _i, _j, _ref, _ref1, _ref2;
      ac = atom.context;
      ac.lineWidth = 2;
      if (this.invalidPlacement) {
        ac.strokeStyle = '#a99';
      } else {
        ac.strokeStyle = '#999';
      }
      for (j = _i = 0, _ref = this.h; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
        for (i = _j = 0, _ref1 = this.w; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          _ref2 = [this.x + this.CELLSIZE * i, this.y + this.CELLSIZE * j, this.CELLSIZE, this.CELLSIZE, this.x + this.CELLSIZE * i + this.CELLSIZE * 0.5, this.y + this.CELLSIZE * j + this.CELLSIZE * 0.5], x = _ref2[0], y = _ref2[1], w = _ref2[2], h = _ref2[3], cx = _ref2[4], cy = _ref2[5];
          if (this.invalidPlacement) {
            ac.fillStyle = '#dbc';
          } else {
            ac.fillStyle = '#abc';
          }
          ac.fillRect(x, y, w, h);
          ac.strokeRect(x, y, w, h);
          if (this.invalidPlacement) {
            ac.fillStyle = '#a89';
          } else {
            ac.fillStyle = '#789';
          }
          ac.beginPath();
          ac.arc(cx, cy, 8, 0, 2 * Math.PI, true);
          ac.fill();
          ac.stroke();
        }
      }
      if (this.invalidPlacement) {
        ac.strokeStyle = '#500';
      } else {
        ac.strokeStyle = '#000';
      }
      ac.lineWidth = this.BORDERSIZE;
      return ac.strokeRect(this.x + this.BORDERSIZE_ + 1, this.y + this.BORDERSIZE_ + 1, this.w * this.CELLSIZE - this.BORDERSIZE + 2, this.h * this.CELLSIZE - this.BORDERSIZE + 2);
    };

    function MoveTile(params) {
      var k, sides, v, _ref;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (this.size != null) {
        sides = this.size.split('x');
        if (sides[0] > sides[1]) {
          this.w = sides[0];
          this.h = sides[1];
        } else {
          this.w = sides[1];
          this.h = sides[0];
        }
        _ref = [parseInt(this.w), parseInt(this.h)], this.w = _ref[0], this.h = _ref[1];
      }
    }

    return MoveTile;

  })();
  Button = (function() {

    Button.prototype.x = 0;

    Button.prototype.y = 0;

    Button.prototype.w = 0;

    Button.prototype.h = 0;

    Button.prototype.containsPoint = function(x, y) {
      return ((this.x <= x && x <= this.x + this.w)) && ((this.y <= y && y <= this.y + this.h));
    };

    Button.prototype.state = 'up';

    Button.prototype.color = {
      pressed: '#b00',
      up: '#f00'
    };

    Button.prototype.draw = function() {
      var ac;
      ac = atom.context;
      ac.lineWidth = 2;
      ac.strokeStyle = '#111';
      ac.fillStyle = this.color[this.state];
      ac.fillRect(this.x, this.y, this.w, this.h);
      return ac.strokeRect(this.x, this.y, this.w, this.h);
    };

    function Button(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
    }

    return Button;

  })();
  return Kulami = (function(_super) {

    __extends(Kulami, _super);

    Kulami.prototype.getLayoutOrigin = function() {
      var maxX, maxY, minX, minY, t, _i, _len, _ref;
      minX = Infinity;
      maxX = 0;
      minY = Infinity;
      maxY = 0;
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        if ((t.x >> 5) < minX) {
          minX = t.x >> 5;
        }
        if ((t.y >> 5) < minY) {
          minY = t.y >> 5;
        }
        if ((t.x >> 5) + t.w > maxX) {
          maxX = (t.x >> 5) + t.w;
        }
        if ((t.y >> 5) + t.h > maxY) {
          maxY = (t.y >> 5) + t.h;
        }
      }
      this.user.layout.x = minX;
      this.user.layout.y = minY;
      this.user.layout.bx = maxX;
      return this.user.layout.by = maxY;
    };

    Kulami.prototype.verifyLayoutValid = function() {
      var i, layout, minX, minY, t, x, y, _i, _j, _k, _len, _ref, _ref1, _ref2;
      this.getLayoutOrigin();
      layout = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = (this.user.layout.bx + 1) * (this.user.layout.by + 1); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(0);
        }
        return _results;
      }).call(this);
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        minX = this.user.layout.x + (t.x >> 5);
        minY = this.user.layout.y + (t.y >> 5);
        for (y = _j = 0, _ref1 = t.h; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          for (x = _k = 0, _ref2 = t.w; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; x = 0 <= _ref2 ? ++_k : --_k) {
            layout[(minY + y) * this.user.layout.bx + (minX + x)]++;
            if (layout[(minY + y) * this.user.layout.bx + (minX + x)] > 1) {
              t.invalidPlacement = true;
              return false;
            }
          }
        }
        t.invalidPlacement = false;
      }
      return true;
    };

    Kulami.prototype.findUIThing = function(thingType) {
      var k, mx, my, t, v, _i, _len, _ref, _ref1;
      mx = atom.input.mouse.x;
      my = atom.input.mouse.y;
      switch (thingType) {
        case 'tiles':
          _ref = this.tiles;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            t = _ref[_i];
            if (t.containsPoint(mx, my)) {
              this.user.tile = t;
              this.user.mouseOffset.x = mx - t.x;
              this.user.mouseOffset.y = my - t.y;
              return true;
            }
          }
          break;
        case 'buttons':
          _ref1 = this.buttons;
          for (k in _ref1) {
            v = _ref1[k];
            if (v.containsPoint(mx, my)) {
              this.user.lastButton = v;
              return true;
            }
          }
          this.user.lastButton = null;
      }
      return false;
    };

    Kulami.prototype.user = {
      lastClick: 0,
      lastButton: null,
      lastTile: null,
      tile: null,
      layout: {
        x: 0,
        y: 0,
        bx: 0,
        by: 0
      },
      mouseOffset: {
        x: 0,
        y: 0
      }
    };

    Kulami.prototype.mode = {
      current: 'select',
      play: function(dt) {
        if (atom.input.down('touchfinger') || atom.input.down('mouseleft')) {
          return atom.playSound('crack');
        }
      },
      select: function(dt) {
        if (atom.input.down('touchfinger') || atom.input.down('mouseleft')) {
          if (this.findUIThing('tiles')) {
            if (this.user.lastTile === this.user.tile && this.user.lastClick < 0.3) {
              this.user.tile.transposeOrientation();
              atom.playSound('drop');
              this.user.lastTile = null;
            } else {
              this.user.lastClick = 0;
              this.mode.current = 'move';
              this.user.lastTile = this.user.tile;
              atom.playSound('pick');
            }
          }
          this.user.lastClick += dt;
        }
        if (atom.input.released('touchfinger') || atom.input.released('mouseleft')) {
          if (this.findUIThing('buttons')) {
            atom.playSound('drop');
            if (this.user.lastButton.clicked != null) {
              return this.triggers[this.user.lastButton.clicked].apply(this);
            }
          }
        }
      },
      move: function(dt) {
        if ((atom.input.released('touchfinger') || atom.input.released('mouseleft')) && (this.user.tile != null)) {
          this.user.lastClick = 0;
          this.mode.current = 'select';
          this.user.tile.x = 32 * Math.round(this.user.tile.x * 0.03125);
          this.user.tile.y = 32 * Math.round(this.user.tile.y * 0.03125);
          atom.playSound('drop');
          if (this.verifyLayoutValid() === true) {
            return this.triggers.enablestartbutton.call(this);
          } else {
            return this.triggers.disablestartbutton.call(this);
          }
        } else {
          this.user.lastClick += dt;
          this.user.tile.x = atom.input.mouse.x - this.user.mouseOffset.x;
          return this.user.tile.y = atom.input.mouse.y - this.user.mouseOffset.y;
        }
      }
    };

    Kulami.prototype.triggers = {
      removestartbutton: function() {
        var b;
        b = this.buttons.start;
        if (b != null) {
          return delete this.buttons.start;
        }
      },
      enablestartbutton: function() {
        var b;
        b = this.buttons.start;
        if (b != null) {
          b.color = {
            pressed: '#0a0',
            up: '#3e8'
          };
          return b.clicked = 'startgame';
        }
      },
      disablestartbutton: function() {
        var b;
        b = this.buttons.start;
        if (b != null) {
          b.color = {
            pressed: '#0a0',
            up: '#aeb'
          };
          return b.clicked = null;
        }
      },
      startgame: function() {
        this.mode.current = 'play';
        return this.triggers.removestartbutton.call(this);
      }
    };

    Kulami.prototype.tiles = [];

    Kulami.prototype.buttons = {
      start: new Button({
        x: atom.width - 100,
        y: 20,
        w: 80,
        h: 80,
        clicked: null,
        color: {
          pressed: '#0a0',
          up: '#3e8'
        }
      })
    };

    function Kulami() {
      var i, k, makeTile, tileList, v, _i,
        _this = this;
      tileList = {
        '3x2': 4,
        '2x2': 5,
        '3x1': 4,
        '2x1': 4
      };
      makeTile = function(size) {
        return _this.tiles.push(new MoveTile({
          size: size,
          x: $$.R(1, 300),
          y: $$.R(1, 300)
        }));
      };
      for (k in tileList) {
        v = tileList[k];
        for (i = _i = 0; 0 <= v ? _i < v : _i > v; i = 0 <= v ? ++_i : --_i) {
          makeTile(k);
        }
      }
      atom.input.bind(atom.button.LEFT, 'mouseleft');
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger');
    }

    Kulami.prototype.update = function(dt) {
      return this.mode[this.mode.current].apply(this, [dt]);
    };

    Kulami.prototype.draw = function() {
      var k, t, v, _i, _len, _ref, _ref1, _results;
      atom.context.clear();
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        t.draw();
      }
      _ref1 = this.buttons;
      _results = [];
      for (k in _ref1) {
        v = _ref1[k];
        _results.push(v.draw());
      }
      return _results;
    };

    return Kulami;

  })(atom.Game);
});

// Generated by CoffeeScript 1.5.0-pre
