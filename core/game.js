var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['core/placetiles'], function(placeTiles) {
  var Kulami, MoveTile;
  MoveTile = (function() {

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
      var cx, cy, h, i, j, w, x, y, _i, _ref, _results;
      if (this.transposeOrientation) {

      } else {
        _results = [];
        for (j = _i = 0, _ref = this.h; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _ref2, _results1;
            _results1 = [];
            for (i = _j = 0, _ref1 = this.w; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
              _ref2 = [this.x + this.CELLSIZE * i, this.y + this.CELLSIZE * j, this.CELLSIZE, this.CELLSIZE, this.x + this.CELLSIZE * i + this.CELLSIZE * 0.5, this.y + this.CELLSIZE * j + this.CELLSIZE * 0.5], x = _ref2[0], y = _ref2[1], w = _ref2[2], h = _ref2[3], cx = _ref2[4], cy = _ref2[5];
              atom.context.fillStyle = '#abc';
              atom.context.fillRect(x, y, w, h);
              atom.context.strokeRect(x, y, w, h);
              atom.context.fillStyle = '#789';
              atom.context.beginPath();
              atom.context.arc(cx, cy, 12, 0, 2 * Math.PI, true);
              atom.context.fill();
              _results1.push(atom.context.stroke());
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }
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
      tile: null,
      mouseOffset: {
        x: 0,
        y: 0
      }
    };

    Kulami.prototype.mode = {
      current: 'select',
      select: function() {
        if (atom.input.down('mouseleft') && this.findTile()) {
          return this.mode.current = 'move';
        }
      },
      move: function() {
        if (atom.input.released('mouseleft') && (this.user.tile != null)) {
          this.mode.current = 'select';
          this.user.tile.x = 32 * Math.round(this.user.tile.x * 0.03125);
          return this.user.tile.y = 32 * Math.round(this.user.tile.y * 0.03125);
        } else {
          this.user.tile.x = atom.input.mouse.x - this.user.mouseOffset.x;
          return this.user.tile.y = atom.input.mouse.y - this.user.mouseOffset.y;
        }
      }
    };

    Kulami.prototype.tiles = [];

    function Kulami() {
      var i, makeTile;
      makeTile = function() {
        var h, w;
        w = $$.R(1, 3);
        if (w === 3) {
          h = $$.R(1, 2);
        } else if (w === 1) {
          h = $$.R(2, 3);
        } else {
          h = $$.R(1, 3);
        }
        return new MoveTile({
          size: "" + w + "x" + h,
          x: $$.R(1, 300),
          y: $$.R(1, 300)
        });
      };
      this.tiles = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = $$.R(3, 10); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(makeTile());
        }
        return _results;
      })();
      atom.input.bind(atom.button.LEFT, 'mouseleft');
    }

    Kulami.prototype.update = function(dt) {
      return this.mode[this.mode.current].apply(this);
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
