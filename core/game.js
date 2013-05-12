var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['core/placetiles'], function(placeTiles) {
  var Kulami, MoveTile;
  MoveTile = (function() {

    MoveTile.prototype.BORDERSIZE = 4;

    MoveTile.prototype.BORDERSIZE_ = 0.25;

    MoveTile.prototype.CELLSIZE = 32;

    MoveTile.prototype.size = null;

    MoveTile.prototype.x = 0;

    MoveTile.prototype.y = 0;

    MoveTile.prototype.w = 1;

    MoveTile.prototype.h = 1;

    MoveTile.prototype.transposeOrientation = false;

    MoveTile.prototype.containsPoint = function(x, y) {
      return ((this.x < x && x < this.x + this.CELLSIZE * this.w)) && ((this.y < y && y < this.y + this.CELLSIZE * this.h));
    };

    MoveTile.prototype.draw = function() {
      var cx, cy, h, i, j, w, x, y, _h, _i, _j, _ref, _ref1, _ref2, _w;
      if (this.transposeOrientation) {
        _ref = [this.h, this.w], _w = _ref[0], _h = _ref[1];
      } else {
        _ref1 = [this.w, this.h], _w = _ref1[0], _h = _ref1[1];
      }
      atom.context.lineWidth = 2;
      atom.context.strokeStyle = '#999';
      for (j = _i = 0; 0 <= _h ? _i < _h : _i > _h; j = 0 <= _h ? ++_i : --_i) {
        for (i = _j = 0; 0 <= _w ? _j < _w : _j > _w; i = 0 <= _w ? ++_j : --_j) {
          _ref2 = [this.x + this.CELLSIZE * i, this.y + this.CELLSIZE * j, this.CELLSIZE, this.CELLSIZE, this.x + this.CELLSIZE * i + this.CELLSIZE * 0.5, this.y + this.CELLSIZE * j + this.CELLSIZE * 0.5], x = _ref2[0], y = _ref2[1], w = _ref2[2], h = _ref2[3], cx = _ref2[4], cy = _ref2[5];
          atom.context.fillStyle = '#abc';
          atom.context.fillRect(x, y, w, h);
          atom.context.strokeRect(x, y, w, h);
          atom.context.fillStyle = '#789';
          atom.context.beginPath();
          atom.context.arc(cx, cy, 8, 0, 2 * Math.PI, true);
          atom.context.fill();
          atom.context.stroke();
        }
      }
      atom.context.strokeStyle = '#000';
      atom.context.lineWidth = this.BORDERSIZE;
      return atom.context.strokeRect(this.x + this.BORDERSIZE_ + 1, this.y + this.BORDERSIZE_ + 1, _w * this.CELLSIZE - this.BORDERSIZE + 2, _h * this.CELLSIZE - this.BORDERSIZE + 2);
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
  return Kulami = (function(_super) {

    __extends(Kulami, _super);

    Kulami.prototype.findTile = function() {
      var mx, my, t, _i, _len, _ref;
      mx = atom.input.mouse.x;
      my = atom.input.mouse.y;
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
      return false;
    };

    Kulami.prototype.user = {
      lastClick: 0,
      lastTile: null,
      tile: null,
      mouseOffset: {
        x: 0,
        y: 0
      }
    };

    Kulami.prototype.mode = {
      current: 'select',
      select: function(dt) {
        if (atom.input.down('mouseleft') && this.findTile()) {
          if (this.user.lastTile === this.user.tile && this.user.lastClick < 0.3) {
            console.log(dt, this.user.lastClick);
            this.user.tile.transposeOrientation ^= true;
            atom.playSound('drop');
            this.user.lastTile = null;
          } else {
            this.user.lastClick = 0;
            this.mode.current = 'move';
            this.user.lastTile = this.user.tile;
            atom.playSound('pick');
          }
        }
        return this.user.lastClick += dt;
      },
      move: function(dt) {
        if (atom.input.released('mouseleft') && (this.user.tile != null)) {
          this.user.lastClick = 0;
          this.mode.current = 'select';
          this.user.tile.x = 32 * Math.round(this.user.tile.x * 0.03125);
          this.user.tile.y = 32 * Math.round(this.user.tile.y * 0.03125);
          return atom.playSound('drop');
        } else {
          this.user.lastClick += dt;
          this.user.tile.x = atom.input.mouse.x - this.user.mouseOffset.x;
          return this.user.tile.y = atom.input.mouse.y - this.user.mouseOffset.y;
        }
      }
    };

    Kulami.prototype.tiles = [];

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
    }

    Kulami.prototype.checkNoOverlap = function() {};

    Kulami.prototype.update = function(dt) {
      return this.mode[this.mode.current].apply(this, [dt]);
    };

    Kulami.prototype.draw = function() {
      var t, _i, _len, _ref, _results;
      atom.context.clear();
      _ref = this.tiles;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        _results.push(t.draw());
      }
      return _results;
    };

    return Kulami;

  })(atom.Game);
});

// Generated by CoffeeScript 1.5.0-pre
