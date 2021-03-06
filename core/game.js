var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['core/tile', 'core/button', 'core/instructions', 'core/aistate', 'core/aiplayer'], function(MoveTile, Button, Instructions, AIState, AIPlayer) {
  var BoardGame;
  return BoardGame = (function(_super) {

    __extends(BoardGame, _super);

    BoardGame.prototype.getLayoutOrigin = function() {
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

    BoardGame.prototype.verifyLayoutValid = function() {
      var i, layout, minX, minY, t, x, y, _i, _j, _k, _ref, _ref1, _ref2;
      this.getLayoutOrigin();
      layout = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = (this.user.layout.bx + 1) * (this.user.layout.by + 1); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(0);
        }
        return _results;
      }).call(this);
      for (i = _i = _ref = this.tiles.length - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        t = this.tiles[i];
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

    BoardGame.prototype.findTileAt = function(x, y) {
      var t, _i, _len, _ref;
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        if (t.containsPoint(x, y)) {
          return t;
        }
      }
      return null;
    };

    BoardGame.prototype.findUIThing = function(thingType) {
      var i, k, mx, my, t, v, _i, _ref, _ref1;
      mx = atom.input.mouse.x;
      my = atom.input.mouse.y;
      switch (thingType) {
        case 'tiles':
          for (i = _i = _ref = this.tiles.length - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
            t = this.tiles[i];
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

    BoardGame.prototype.translateMouseToLayout = function() {
      return {
        x: ((atom.input.mouse.x >> 5) - this.user.layout.x << 5) >> 5,
        y: ((atom.input.mouse.y >> 5) - this.user.layout.y << 5) >> 5
      };
    };

    BoardGame.prototype.createRandomLayout = function() {
      var holeChance, i, maxX, minX, tilePool, tileToPlace, tryLayingTile, x, y, _ref,
        _this = this;
      tilePool = this.tiles.slice();
      this.tiles = [];
      maxX = 10;
      _ref = [((atom.width >> 5) - maxX) >> 1, 1], x = _ref[0], y = _ref[1];
      minX = x;
      maxX += x;
      holeChance = 0.6;
      this.user.layout.x = x;
      this.user.layout.y = y;
      tryLayingTile = function(t) {
        var i, invalid;
        invalid = true;
        i = 0;
        while (invalid) {
          if (i === 0 && $$.r() > holeChance) {
            t.transposeOrientation();
          } else {
            t.x += 32;
            if (t.x >> 5 > maxX) {
              t.x = minX << 5;
              t.y += 32;
            }
          }
          i++;
          i %= 2;
          invalid = !_this.verifyLayoutValid();
          if (t.y > 40 << 5) {
            return false;
          }
        }
        return true;
      };
      while (tilePool.length > 0) {
        i = $$.R(0, tilePool.length - 1);
        tileToPlace = tilePool[i];
        tilePool.splice(i, 1);
        this.tiles.push(tileToPlace);
        tileToPlace.x = x << 5;
        tileToPlace.y = y << 5;
        if (!tryLayingTile(tileToPlace)) {
          this.tiles = this.tiles.concat(tilePool);
          return false;
        }
        x = tileToPlace.x >> 5;
        y = tileToPlace.y >> 5;
      }
      this.triggers.startgame.call(this);
    };

    BoardGame.prototype.user = {
      moves: 0,
      COLORS: [null, 'red', 'black'],
      color: 1,
      lastClick: 0,
      lastButton: null,
      lastMove: {
        x: -1,
        y: -1
      },
      lastMouse: {
        x: 0,
        y: 0
      },
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

    BoardGame.prototype.checkIfPlayerHasMovesLeft = function() {
      var t, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
      y = this.user.lastMove.y + this.user.layout.y;
      for (x = _i = _ref = this.user.layout.x, _ref1 = this.user.layout.bx; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        t = this.findTileAt(x << 5, y << 5);
        if ((t != null) && t !== this.user.lastTile && t.getOuterCell(x - this.user.layout.x, y - this.user.layout.y) === 0) {
          return true;
        }
      }
      x = this.user.lastMove.x + this.user.layout.x;
      for (y = _j = _ref2 = this.user.layout.y, _ref3 = this.user.layout.by; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
        t = this.findTileAt(x << 5, y << 5);
        if ((t != null) && t !== this.user.lastTile && t.getOuterCell(x - this.user.layout.x, y - this.user.layout.y) === 0) {
          return true;
        }
      }
      return false;
    };

    BoardGame.prototype.mode = {
      current: 'select',
      gameover: function(dt) {
        if (atom.input.pressed('touchfinger') || atom.input.pressed('mouseleft')) {
          if (this.findUIThing('buttons')) {
            atom.playSound('drop');
            if (this.user.lastButton.clicked != null) {
              return this.triggers[this.user.lastButton.clicked].apply(this);
            }
          }
        }
      },
      play: function(dt) {
        var mouse;
        if (atom.input.pressed('touchfinger') || atom.input.pressed('mouseleft')) {
          if (this.findUIThing('tiles')) {
            mouse = this.translateMouseToLayout();
            if ((this.user.tile === this.user.lastTile) || (this.user.tile.getOuterCell(mouse.x, mouse.y) > 0) || (this.user.moves > 0 && (mouse.x !== this.user.lastMove.x && mouse.y !== this.user.lastMove.y))) {
              return this.triggers.showbadmove.call(this);
            } else {
              return this.triggers.movemade.call(this, mouse);
            }
          } else if (this.findUIThing('buttons')) {
            atom.playSound('drop');
            if (this.user.lastButton.clicked != null) {
              return this.triggers[this.user.lastButton.clicked].apply(this);
            }
          }
        }
      },
      select: function(dt) {
        var front, frontIndex;
        this.user.lastClick += dt;
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
              frontIndex = this.tiles.indexOf(this.user.lastTile);
              if (frontIndex !== this.tiles.length - 1) {
                front = this.tiles[frontIndex];
                this.tiles.splice(frontIndex, 1);
                this.tiles.push(front);
              }
              atom.playSound('pick');
            }
          }
        }
        if (atom.input.pressed('touchfinger') || atom.input.pressed('mouseleft')) {
          if (this.findUIThing('buttons')) {
            atom.playSound('drop');
            if (this.user.lastButton.clicked != null) {
              return this.triggers[this.user.lastButton.clicked].apply(this);
            }
          }
        }
      },
      move: function(dt) {
        var diff, magnitude, newRotation, sign;
        this.user.lastClick += dt;
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
          this.user.tile.y = atom.input.mouse.y - this.user.mouseOffset.y;
          diff = {
            x: atom.input.mouse.x - this.user.lastMouse.x,
            y: atom.input.mouse.y - this.user.lastMouse.y
          };
          magnitude = Math.abs(diff.x) + Math.abs(diff.y);
          sign = diff.x > 0 ? 1 : -1;
          if (magnitude !== 0) {
            newRotation = Math.log(magnitude) * 0.16 * sign;
          }
          if (!(Math.abs(newRotation) < 0.09 || !(newRotation != null))) {
            this.user.tile.rotation = newRotation;
          }
          return this.user.lastMouse = {
            x: atom.input.mouse.x,
            y: atom.input.mouse.y
          };
        }
      }
    };

    BoardGame.prototype.triggers = {
      tallyscore: function() {
        var t, _i, _len, _ref;
        _ref = this.tiles;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          if (!t.finalTallied) {
            this.finaltiles.push(t);
            this.tiles.splice(this.tiles.indexOf(t), 1);
            t.finalTallied = true;
            break;
          }
        }
      },
      movemade: function(coord) {
        var _this = this;
        this.user.tile.setOuterCell(coord.x, coord.y, this.user.color);
        this.user.lastTile = this.user.tile;
        this.user.color++;
        if (this.user.color > 2) {
          this.user.color = 1;
        }
        this.triggers.removehighlightbutton.apply(this);
        this.user.lastMove = coord;
        this.user.moves++;
        atom.playSound('crack');
        this.triggers.addhighlightbutton.apply(this);
        if (!this.checkIfPlayerHasMovesLeft()) {
          this.triggers.showgameover.call(this);
          alert('No moves left for ' + this.user.COLORS[this.user.color] + '!');
          return this.triggers.calculatescores.call(this);
        } else {
          this.triggers.showwhosturn.call(this);
          if (this.ai != null) {
            this.aistate.updateBoard();
            if (this.user.color === this.ai.color) {
              this.aistate.calculateTauntBasedOnScore();
              return setTimeout((function() {
                return _this.ai.makeMove();
              }), $$.R(200, 900));
            }
          }
        }
      },
      showgameover: function() {
        this.instructions.set({
          name: 'NEUTRAL_GAMEOVER'
        });
        this.triggers.removehelpbutton.call(this);
        return this.triggers.addrestartgamebutton.call(this);
      },
      showbadmove: function() {
        atom.playSound('invalid');
        this.instructions.set({
          name: 'BAD_MOVEINVALID'
        });
        return this.triggers.removehelpnavigationbuttons.call(this);
      },
      showwhosturn: function() {
        this.instructions.set({
          name: 'NEUTRAL_' + this.user.COLORS[this.user.color].toUpperCase() + 'STURN'
        });
        return this.triggers.removehelpnavigationbuttons.call(this);
      },
      removehelpnavigationbuttons: function() {
        if (this.buttons.fastForward != null) {
          delete this.buttons.fastForward;
        }
        if (this.buttons.rewind != null) {
          return delete this.buttons.rewind;
        }
      },
      disablehelprewind: function() {
        var b;
        b = this.buttons.rewind;
        if (b != null) {
          b.color.opacity = 0.5;
          return b.clicked = null;
        }
      },
      enablehelprewind: function() {
        var b;
        b = this.buttons.rewind;
        if (b != null) {
          delete b.color.opacity;
          return b.clicked = 'helprewind';
        }
      },
      disablehelpfastforward: function() {
        var b;
        b = this.buttons.fastforward;
        if (b != null) {
          b.color.opacity = 0.4;
          return b.clicked = null;
        }
      },
      enablehelpfastforward: function() {
        var b;
        b = this.buttons.fastforward;
        if (b != null) {
          delete b.color.opacity;
          return b.clicked = 'helpfastforward';
        }
      },
      helpfastforward: function() {
        return this.instructions.nextInSequence();
      },
      helprewind: function() {
        return this.instructions.prevInSequence();
      },
      addhelpnavigationbuttons: function() {
        this.buttons.fastForward = new Button({
          x: atom.width - 171,
          y: atom.height - 60,
          hOffset: 171,
          w: 61,
          h: 50,
          shape: 'image',
          image: 'button_fastforward',
          clicked: 'helpfastforward',
          color: {
            pressed: '#F7C839',
            up: '#F7C839'
          }
        });
        this.buttons.rewind = new Button({
          x: atom.width - 242,
          y: atom.height - 60,
          hOffset: 242,
          w: 61,
          h: 50,
          shape: 'image',
          image: 'button_rewind',
          clicked: 'helprewind',
          color: {
            pressed: '#F7C839',
            up: '#F7C839'
          }
        });
        return this.triggers.disablehelprewind.call(this);
      },
      addhighlightbutton: function() {
        return this.buttons.highlightLastMove = new Button({
          x: (this.user.layout.x + this.user.lastMove.x) << 5,
          y: (this.user.layout.y + this.user.lastMove.y) << 5,
          w: 16,
          shape: 'circle',
          clicked: null,
          color: {
            opacity: 0.4,
            pressed: '#F7C8F9',
            up: '#F7C8F9'
          }
        });
      },
      removehighlightbutton: function() {
        if (this.buttons.highlightLastMove != null) {
          return delete this.buttons.highlightLastMove;
        }
      },
      removerandomlayoutbutton: function() {
        if (this.buttons.randomLayout != null) {
          return delete this.buttons.randomLayout;
        }
      },
      removehelpbutton: function() {
        if (this.buttons.help != null) {
          delete this.buttons.help;
        }
        return this.triggers.removehelpnavigationbuttons.call(this);
      },
      removestartbutton: function() {
        if (this.buttons.start != null) {
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
            up: '#aeb',
            opacity: 0.2
          };
          return b.clicked = 'invalidstart';
        }
      },
      startgame: function() {
        var t, _i, _len, _ref;
        _ref = this.tiles;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          t.lockOrientation();
          t.lx = (t.x >> 5) - this.user.layout.x;
          t.ly = (t.y >> 5) - this.user.layout.y;
        }
        this.triggers.removestartbutton.call(this);
        this.triggers.removerandomlayoutbutton.call(this);
        this.buttons.help.clicked = 'showgameruleshelp';
        this.mode.current = 'play';
        this.user.lastTile = null;
        atom.playSound('valid');
        this.triggers.showwhosturn.call(this);
        this.aistate = new AIState({
          game: this
        });
        this.ai = new AIPlayer({
          game: this
        });
        return this.aistate.setBoard();
      },
      generaterandomlayout: function() {
        return this.createRandomLayout();
      },
      invalidstart: function() {
        return atom.playSound('invalid');
      },
      calculatescores: function() {
        var endquip, i, scoreWithinTile, scores, t, _i, _j, _len, _len1, _ref, _ref1;
        scores = {
          red: 0,
          black: 0
        };
        _ref = this.tiles;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          scoreWithinTile = {
            red: 0,
            black: 0
          };
          _ref1 = t.cells;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            i = _ref1[_j];
            switch (i) {
              case 1:
                scoreWithinTile.red++;
                break;
              case 2:
                scoreWithinTile.black++;
            }
          }
          if (scoreWithinTile.red > scoreWithinTile.black) {
            scores.red += t.w * t.h;
          } else if (scoreWithinTile.red < scoreWithinTile.black) {
            scores.black += t.w * t.h;
          }
        }
        if (scores.black > scores.red) {
          endquip = 'Black wins.';
        } else if (scores.black === scores.red) {
          endquip = 'Draw.';
        } else {
          endquip = 'Red wins.';
        }
        if (this.ai) {
          if (this.ai.color === 2) {
            if (scores.black > scores.red) {
              endquip += '\nYou lose, human!';
              this.aistate.calculateTauntBasedOnScore();
            }
          }
        }
        this.instructions.NEUTRAL_GAMEOVER.text = "GAME OVER!\n\nFinal scores:\nRED -> " + scores.red + "\nBLACK -> " + scores.black + "\n\n" + endquip;
        this.instructions.set({
          name: 'NEUTRAL_GAMEOVER'
        });
        this.triggers.tallyscore.call(this);
        return this.mode.current = 'gameover';
      },
      showgameruleshelp: function() {
        this.instructions.set({
          name: 'HELP'
        });
        return this.triggers.addhelpnavigationbuttons.call(this);
      },
      showtileplacementhelp: function() {
        return this.instructions.set({
          name: 'NEUTRAL_BOARDSETUP'
        });
      },
      addrestartgamebutton: function() {
        return this.buttons.restart = new Button({
          x: atom.width - 10 - 136,
          y: atom.height - 60,
          hOffset: 136,
          w: 136,
          h: 50,
          shape: 'image',
          image: 'button_restart',
          clicked: 'reloadpage'
        });
      },
      reloadpage: function() {
        return window.location.reload();
      },
      horizontalorientation: function() {
        this.instructions.vOffset = 0;
        this.triggers.reflowbuttons.call(this);
      },
      verticalorientation: function() {
        this.instructions.vOffset = 50;
        this.triggers.reflowbuttons.call(this);
      },
      reflowbuttons: function() {
        var k, v, _ref;
        _ref = this.buttons;
        for (k in _ref) {
          v = _ref[k];
          if (v.image != null) {
            v.x = atom.width - v.hOffset;
            v.y = atom.height - 60;
          }
        }
      }
    };

    BoardGame.prototype.tiles = [];

    BoardGame.prototype.finaltiles = [];

    BoardGame.prototype.buttons = {
      randomLayout: new Button({
        x: atom.width - 248,
        y: atom.height - 60,
        hOffset: 248,
        w: 138,
        h: 50,
        shape: 'image',
        image: 'button_random',
        clicked: 'generaterandomlayout',
        color: {
          pressed: '#d3f',
          up: '#d3f'
        }
      }),
      start: new Button({
        x: atom.width - 347,
        y: atom.height - 60,
        hOffset: 347,
        w: 90,
        h: 50,
        shape: 'image',
        image: 'button_play',
        clicked: null,
        color: {
          pressed: '#0a0',
          up: '#3e8'
        }
      }),
      help: new Button({
        x: atom.width - 100,
        y: atom.height - 60,
        hOffset: 100,
        w: 89,
        h: 50,
        shape: 'image',
        image: 'button_help',
        clicked: 'showtileplacementhelp',
        color: {
          pressed: '#0a0',
          up: '#3e8'
        }
      })
    };

    function BoardGame() {
      var i, k, makeTile, tileList, v, _i,
        _this = this;
      makeTile = function(size) {
        return _this.tiles.push(new MoveTile({
          size: size,
          x: $$.R(1, 200),
          y: $$.R(1, 200)
        }));
      };
      tileList = {
        '3x2': 4,
        '2x2': 5,
        '3x1': 4,
        '2x1': 4
      };
      for (k in tileList) {
        v = tileList[k];
        for (i = _i = 0; 0 <= v ? _i < v : _i > v; i = 0 <= v ? ++_i : --_i) {
          makeTile(k);
        }
      }
      atom.input.bind(atom.button.LEFT, 'mouseleft');
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger');
      window.onblur = function() {
        return _this.stop;
      };
      window.onfocus = function() {
        return _this.run;
      };
      this.triggers.disablestartbutton.call(this);
      this.instructions = new Instructions({
        game: this,
        verticaloffset: 0
      });
    }

    BoardGame.prototype.update = function(dt) {
      return this.mode[this.mode.current].apply(this, [dt]);
    };

    BoardGame.prototype.draw = function() {
      var k, t, v, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      atom.context.clear();
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        t.draw();
      }
      _ref1 = this.buttons;
      for (k in _ref1) {
        v = _ref1[k];
        v.draw();
      }
      _ref2 = this.finaltiles;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        t = _ref2[_j];
        t.draw();
      }
      return this.instructions.draw();
    };

    return BoardGame;

  })(atom.Game);
});

// Generated by CoffeeScript 1.5.0-pre
