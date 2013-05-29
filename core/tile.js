
define(function() {
  var MoveTile;
  return MoveTile = (function() {

    MoveTile.prototype.BORDERSIZE = 4;

    MoveTile.prototype.BORDERSIZE_ = 0.25;

    MoveTile.prototype.CELLSIZE = 32;

    MoveTile.prototype.size = null;

    MoveTile.prototype.score = 0;

    MoveTile.prototype.x = 0;

    MoveTile.prototype.y = 0;

    MoveTile.prototype.w = 1;

    MoveTile.prototype.h = 1;

    MoveTile.prototype.lx = 0;

    MoveTile.prototype.ly = 0;

    MoveTile.prototype.rotation = 0;

    MoveTile.prototype.invalidPlacement = true;

    MoveTile.prototype.finalTallied = false;

    MoveTile.prototype.finalScore = null;

    MoveTile.prototype.finalColor = null;

    MoveTile.prototype.finalTextOffset = null;

    MoveTile.prototype.opacity = 1;

    MoveTile.prototype.firedNextTally = false;

    MoveTile.prototype.cells = null;

    MoveTile.prototype.transposeOrientation = function() {
      var _h, _ref, _w;
      _ref = [this.w, this.h], _w = _ref[0], _h = _ref[1];
      this.w = _h;
      return this.h = _w;
    };

    MoveTile.prototype.containsPoint = function(x, y) {
      return ((this.x <= x && x < this.x + this.CELLSIZE * this.w)) && ((this.y <= y && y < this.y + this.CELLSIZE * this.h));
    };

    MoveTile.prototype.lockOrientation = function() {
      var i;
      this.score = this.w * this.h;
      return this.cells = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.score; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(0);
        }
        return _results;
      }).call(this);
    };

    MoveTile.prototype.getInnerCell = function(x, y) {
      return this.cells[this.w * y + x];
    };

    MoveTile.prototype.getOuterCell = function(x, y) {
      return this.getInnerCell(x - this.lx, y - this.ly);
    };

    MoveTile.prototype.setInnerCell = function(x, y, v) {
      return this.cells[this.w * y + x] = v;
    };

    MoveTile.prototype.setOuterCell = function(x, y, v) {
      return this.setInnerCell(x - this.lx, y - this.ly, v);
    };

    MoveTile.prototype.getCentroid = function() {
      return {
        x: this.x + this.w * this.CELLSIZE * 0.5,
        y: this.y + this.h * this.CELLSIZE * 0.5
      };
    };

    MoveTile.prototype.draw = function() {
      var ac, black, c, color, cx, cy, h, i, img, j, lx, ly, red, rotationMagnitude, strokeStyleDark, strokeStyleLight, text, w, x, y, _i, _j, _k, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      ac = atom.context;
      c = this.getCentroid();
      ac.save();
      ac.translate(c.x, c.y);
      if (this.finalTallied) {
        if (this.opacity > 0.3) {
          this.opacity -= 0.05;
        }
        ac.globalAlpha = this.opacity;
      } else {
        rotationMagnitude = Math.abs(this.rotation);
        if (rotationMagnitude > 0) {
          this.rotation *= 0.6;
          if (rotationMagnitude < 0.001) {
            this.rotation = 0;
          }
        }
        if (this.rotation !== 0) {
          ac.rotate(this.rotation);
        }
      }
      ac.lineWidth = 2;
      for (j = _i = 0, _ref = this.h; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
        for (i = _j = 0, _ref1 = this.w; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          _ref2 = [this.CELLSIZE * (i - this.w * 0.5), this.CELLSIZE * (j - this.h * 0.5), this.CELLSIZE, this.CELLSIZE, this.CELLSIZE * (i - this.w * 0.5) + this.CELLSIZE * 0.5, this.CELLSIZE * (j - this.h * 0.5) + this.CELLSIZE * 0.5], x = _ref2[0], y = _ref2[1], w = _ref2[2], h = _ref2[3], cx = _ref2[4], cy = _ref2[5];
          if ((this.cells != null) && this.cells[this.w * j + i] > 0) {
            if (this.cells[this.w * j + i] === 1) {
              img = atom.gfx.cell_red;
            } else {
              img = atom.gfx.cell_black;
            }
          } else {
            img = atom.gfx.cell_;
          }
          ac.drawImage(img, x, y);
        }
      }
      if (this.invalidPlacement) {
        strokeStyleDark = '#f00';
        strokeStyleLight = '#f88';
      } else {
        strokeStyleDark = '#333';
        strokeStyleLight = '#88f';
      }
      _ref3 = [this.CELLSIZE * (-this.w * 0.5), this.CELLSIZE * (-this.h * 0.5)], x = _ref3[0], y = _ref3[1];
      _ref4 = [x + this.BORDERSIZE_ + 1, y + this.BORDERSIZE_ + 1], lx = _ref4[0], ly = _ref4[1];
      ac.strokeStyle = strokeStyleDark;
      ac.lineWidth = this.BORDERSIZE;
      ac.lineJoin = 'round';
      ac.strokeRect(lx, ly, this.w * this.CELLSIZE - this.BORDERSIZE + 2, this.h * this.CELLSIZE - this.BORDERSIZE + 2);
      if (this.finalTallied === true) {
        if (this.opacity <= 0.3) {
          ac.globalCompositeOperation = 'source-over';
          ac.font = 'bold 30px Helvetica';
          if ((this.finalScore != null) && (this.finalColor != null) && (this.finalTextOffset != null)) {

          } else {
            red = 0;
            black = 0;
            _ref5 = this.cells;
            for (_k = 0, _len = _ref5.length; _k < _len; _k++) {
              color = _ref5[_k];
              switch (color) {
                case 1:
                  red++;
                  break;
                case 2:
                  black++;
              }
            }
            this.finalScore = this.score;
            if (red === black) {
              this.finalScore = '-';
              this.finalColor = '#666';
            } else if (red > black) {
              this.finalColor = '#f00';
            } else {
              this.finalColor = '#222';
            }
            text = ac.measureText(this.finalScore);
            this.finalTextOffset = {
              x: -(text.width >> 1),
              y: 10
            };
          }
          ac.fillStyle = this.finalColor;
          ac.globalAlpha = 1;
          ac.fillText(this.finalScore, this.finalTextOffset.x, this.finalTextOffset.y);
          ac.globalAlpha = this.opacity;
          if (!this.firedNextTally) {
            atom.playSound('drop');
            this.firedNextTally = true;
            setTimeout(function() {
              return window.game.triggers.tallyscore.call(window.game);
            }, 300);
          }
        }
      }
      return ac.restore();
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
});

// Generated by CoffeeScript 1.5.0-pre
