// Generated by CoffeeScript 1.4.0

define(function() {
  var AIPlayer;
  return AIPlayer = (function() {

    AIPlayer.prototype.color = 2;

    function AIPlayer(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (!(this.game != null)) {
        throw new Error('no game reference was given to create the state object!');
      }
    }

    AIPlayer.prototype.makeMove = function() {
      var move;
      move = this.game.aistate.findBestMove();
      if (!(move.tile != null)) {
        move = this.game.aistate.findBestMove(true);
      }
      this.game.user.tile = move.tile;
      return this.game.triggers.movemade.call(this.game, move);
    };

    AIPlayer.prototype.makeSnarkyRemark = function(type) {
      var taunt;
      switch (type) {
        case 'GOOD':
          taunt = $$.WR({
            'r_excellent': 2,
            'r_good': 3,
            'r_haha': 2,
            'r_damn': 1,
            'r_damnit': 1,
            'silence': 4
          });
          break;
        case 'BAD':
          taunt = $$.WR({
            'r_haha': 4,
            'r_slow': 2,
            'r_fate': 1,
            'r_disturb': 1,
            'silence': 3
          });
          break;
        case 'NEUTRAL':
          taunt = $$.WR({
            'r_slow': 1,
            'r_longenough': 1,
            'r_haha': 2,
            'r_damn': 1,
            'silence': 4
          });
      }
      console.log('taunt attempt:', taunt);
      if ((taunt != null) && taunt !== 'silence') {
        if ($$.r() < 0.2) {
          return atom.playSound(taunt);
        }
      }
    };

    return AIPlayer;

  })();
});
