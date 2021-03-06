
define(function() {
  var AIState;
  return AIState = (function() {

    AIState.prototype.color = 2;

    function AIState(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (!(this.game != null)) {
        throw new Error('no game reference was given to create the state object!');
      }
    }

    AIState.prototype.countAvailableMovesFromCell = function(refcell, x, y) {
      var cell, i, j, movesAvailable, _i, _j, _ref, _ref1;
      movesAvailable = 0;
      if ((x == null) || (y == null)) {
        x = refcell.x;
        y = refcell.y;
      } else if (refcell == null) {
        refcell = this.board[y * this.boardW + x];
      }
      for (i = _i = 0, _ref = this.boardW; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        cell = this.board[i + this.boardW * y];
        if (cell.control === 0 && cell.value >= 0 && refcell !== cell && cell.tile !== this.game.user.lastTile) {
          movesAvailable++;
        }
      }
      for (j = _j = 0, _ref1 = this.boardH; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        cell = this.board[x + this.boardW * j];
        if (cell.control === 0 && cell.value >= 0 && refcell !== cell && cell.tile !== this.game.user.lastTile) {
          movesAvailable++;
        }
      }
      return movesAvailable;
    };

    AIState.prototype.setBoard = function() {
      var cell, cx, cy, i, j, t, _i, _j, _k, _len, _ref, _ref1, _ref2;
      this.boardW = this.game.user.layout.bx - this.game.user.layout.x;
      this.boardH = this.game.user.layout.by - this.game.user.layout.y;
      this.board = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.boardW * this.boardH; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push({
            control: -1,
            value: -1,
            tile: null
          });
        }
        return _results;
      }).call(this);
      _ref = this.game.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        for (i = _j = 0, _ref1 = t.h; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          for (j = _k = 0, _ref2 = t.w; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; j = 0 <= _ref2 ? ++_k : --_k) {
            cx = t.lx + j;
            cy = t.ly + i;
            cell = this.board[cy * this.boardW + cx];
            cell.control = 0;
            cell.value = 0;
            cell.x = cx;
            cell.y = cy;
            cell.tile = t;
          }
        }
      }
      return this.updateBoard();
    };

    AIState.prototype.updateBoard = function() {
      var cell, cx, cy, i, j, marblesOnTile, t, _i, _j, _k, _l, _len, _m, _ref, _ref1, _ref2, _ref3, _ref4;
      _ref = this.game.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        marblesOnTile = {
          'red': 0,
          'black': 0
        };
        for (i = _j = 0, _ref1 = t.h; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          for (j = _k = 0, _ref2 = t.w; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; j = 0 <= _ref2 ? ++_k : --_k) {
            cx = t.lx + j;
            cy = t.ly + i;
            cell = this.board[cy * this.boardW + cx];
            if (cell.control === 0 && cx === this.game.user.lastMove.x && cy === this.game.user.lastMove.y) {
              cell.control = ((this.game.user.color + 1) % 2) + 1;
            } else {
              if (cell.control === 0) {
                cell.value = this.countAvailableMovesFromCell(cell) + t.score;
              } else {
                if (cell.control === 1) {
                  marblesOnTile.red++;
                } else if (cell.control === 2) {
                  marblesOnTile.black++;
                }
              }
            }
          }
        }
        if (Math.max(marblesOnTile.red, marblesOnTile.black) > t.score >> 1) {
          for (i = _l = 0, _ref3 = t.h; 0 <= _ref3 ? _l < _ref3 : _l > _ref3; i = 0 <= _ref3 ? ++_l : --_l) {
            for (j = _m = 0, _ref4 = t.w; 0 <= _ref4 ? _m < _ref4 : _m > _ref4; j = 0 <= _ref4 ? ++_m : --_m) {
              cx = t.lx + j;
              cy = t.ly + i;
              cell = this.board[cy * this.boardW + cx];
              cell.value = -1;
            }
          }
        }
      }
    };

    AIState.prototype.findBestMove = function(includeNonOptimalMoves) {
      var bestMove, cell, i, j, lastMove, _i, _j, _ref, _ref1;
      if (includeNonOptimalMoves == null) {
        includeNonOptimalMoves = false;
      }
      if (includeNonOptimalMoves) {
        console.log('ai just tried to look for, merely, a legal move!');
      }
      lastMove = {
        x: this.game.user.lastMove.x,
        y: this.game.user.lastMove.y,
        tile: this.game.user.lastTile
      };
      bestMove = {
        x: -1,
        y: -1,
        value: -2
      };
      for (i = _i = 0, _ref = this.boardW; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        cell = this.board[i + this.boardW * lastMove.y];
        if (includeNonOptimalMoves) {
          if (cell.control === 0 && cell.value >= -1 && i !== lastMove.x && cell.tile !== lastMove.tile) {
            if (cell.value >= bestMove.value) {
              bestMove = {
                x: i,
                y: lastMove.y,
                value: cell.value,
                tile: cell.tile
              };
            }
          }
        } else {
          if (cell.control === 0 && cell.value >= 0 && i !== lastMove.x && cell.tile !== lastMove.tile) {
            if (cell.value >= bestMove.value) {
              bestMove = {
                x: i,
                y: lastMove.y,
                value: cell.value,
                tile: cell.tile
              };
            }
          }
        }
      }
      for (j = _j = 0, _ref1 = this.boardH; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        cell = this.board[lastMove.x + this.boardW * j];
        if (includeNonOptimalMoves) {
          if (cell.control === 0 && cell.value >= -1 && j !== lastMove.y && cell.tile !== lastMove.tile) {
            if (cell.value >= bestMove.value) {
              bestMove = {
                x: lastMove.x,
                y: j,
                value: cell.value,
                tile: cell.tile
              };
            }
          }
        } else {
          if (cell.control === 0 && cell.value >= 0 && j !== lastMove.y && cell.tile !== lastMove.tile) {
            if (cell.value >= bestMove.value) {
              bestMove = {
                x: lastMove.x,
                y: j,
                value: cell.value,
                tile: cell.tile
              };
            }
          }
        }
      }
      return bestMove;
    };

    AIState.prototype.calculateTauntBasedOnScore = function() {
      var i, scoreWithinTile, scores, t, _i, _j, _len, _len1, _ref, _ref1;
      scores = {
        red: 0,
        black: 0
      };
      _ref = this.game.tiles;
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
      if (this.color === 2) {
        if (scores.black > scores.red) {
          return this.game.ai.makeSnarkyRemark('BAD');
        } else if (scores.black <= scores.red) {
          return this.game.ai.makeSnarkyRemark('GOOD');
        } else {
          return this.game.ai.makeSnarkyRemark('NEUTRAL');
        }
      }
    };

    return AIState;

  })();
});

// Generated by CoffeeScript 1.5.0-pre
