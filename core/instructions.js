
define(function() {
  var Instructions;
  return Instructions = (function() {

    Instructions.prototype.NEUTRAL_BOARDSETUP = {
      text: 'Construct board layout.\n\nDrag the tiles to form a board of \nnon-overlapping tiles. Overlapped\ntiles are shown in red. Double click \na tile to change its rotation.',
      audio: null,
      time: Infinity
    };

    Instructions.prototype.BAD_BOARDINVALID = {
      text: 'Illegal board layout!',
      audio: null,
      time: 0
    };

    Instructions.prototype.BAD_MOVEINVALID = {
      text: 'Illegal move!',
      audio: null,
      time: 100
    };

    Instructions.prototype.NEUTRAL_GAMERULES1 = {
      text: '[1/5] This game is won by scoring. The\nplayer who owns the most cells wins.\nOn each turn, a player places a marble\non an empty spot on a tile.',
      audio: 'gamerules1',
      time: 700
    };

    Instructions.prototype.NEUTRAL_GAMERULES2 = {
      text: '[2/5] A player owns a tile when his\nmarbles take up a majority of the\ncells on the tile.',
      audio: 'gamerules2',
      time: 400
    };

    Instructions.prototype.NEUTRAL_GAMERULES3 = {
      text: '[3/5] A player\'s score is the sum of\nthe cells in owned tiles.',
      audio: null,
      time: 400
    };

    Instructions.prototype.NEUTRAL_GAMERULES4 = {
      text: '[4/5] Players take turns placing one\nmarble (per turn) in an empty cell on\na tile that doesn\'t contain the last\nmove.\nA move is legal only if it lies on the\nsame row or column as the last\nmarble played.',
      audio: 'gamerules3',
      time: 900
    };

    Instructions.prototype.NEUTRAL_GAMERULES5 = {
      text: '[5/5] The game ends when a player has\nno legal moves left on their turn.',
      audio: 'gamerules4',
      time: 300
    };

    Instructions.prototype.NEUTRAL_REDSTURN = {
      text: 'Red\'s turn.',
      audio: null,
      time: Infinity
    };

    Instructions.prototype.NEUTRAL_BLACKSTURN = {
      text: 'Black\'s turn.',
      audio: null,
      time: Infinity
    };

    Instructions.prototype.NEUTRAL_GAMEOVER = {
      text: 'Game over!',
      audio: null,
      time: Infinity
    };

    Instructions.prototype.current = 'NEUTRAL_BOARDSETUP';

    Instructions.prototype.type = 'text';

    Instructions.prototype.timer = Infinity;

    Instructions.prototype.sequenceIndex = null;

    Instructions.prototype.game = null;

    Instructions.prototype.vOffset = 0;

    function Instructions(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      this.HELP = [this.NEUTRAL_GAMERULES1, this.NEUTRAL_GAMERULES2, this.NEUTRAL_GAMERULES3, this.NEUTRAL_GAMERULES4, this.NEUTRAL_GAMERULES5];
    }

    Instructions.prototype.clear = function() {
      return this.current = null;
    };

    Instructions.prototype.set = function(params) {
      var item;
      if (params != null) {
        if (params.name) {
          this.current = params.name;
        }
        if (this[this.current] instanceof Array) {
          item = this[this.current][0];
        } else {
          item = this[this.current];
        }
        this.timer = params.time != null ? params.time : item.time;
        this.type = params.type != null ? params.type : 'text';
        return this.sequenceIndex = 0;
      }
    };

    Instructions.prototype.prevInSequence = function() {
      this.sequenceIndex--;
      if (this.sequenceIndex < 0) {
        this.sequenceIndex = 0;
        this.game.triggers.disablehelprewind.call(this.game);
      }
      if (this.sequenceIndex === 0) {
        this.game.triggers.disablehelprewind.call(this.game);
      }
      this.timer = this[this.current][this.sequenceIndex].time + 1;
      return atom.stopAllSounds();
    };

    Instructions.prototype.nextInSequence = function() {
      this.sequenceIndex++;
      if (this.sequenceIndex < this[this.current].length) {
        this.timer = this[this.current][this.sequenceIndex].time;
        return this.game.triggers.enablehelprewind.call(this.game);
      } else {
        atom.stopAllSounds();
        this.clear();
        return this.game.triggers.showwhosturn.call(this.game);
      }
    };

    Instructions.prototype.draw = function() {
      var ac, audio, i, isSequence, item, l, text, _i, _len;
      if (this.current != null) {
        switch (this.type) {
          case 'text':
            if (this.timer > 0) {
              ac = atom.context;
              ac.font = 'bold 20px Helvetica';
              ac.fillStyle = '#222';
              isSequence = this[this.current] instanceof Array;
              if (isSequence) {
                item = this[this.current][this.sequenceIndex];
              } else {
                item = this[this.current];
              }
              text = item.text.split('\n');
              audio = item.audio;
              if ((audio != null) && this.timer === item.time) {
                atom.stopAllSounds();
                atom.playSound(audio);
              }
              i = 0;
              for (_i = 0, _len = text.length; _i < _len; _i++) {
                l = text[_i];
                ac.fillText(l.toUpperCase(), 10, atom.height - this.vOffset - (20 * (text.length - i)));
                i++;
              }
              this.timer--;
              if (isSequence && this.timer === 0) {
                this.nextInSequence();
              }
            }
            break;
          case 'alert':
            if (this.timer > 0) {
              alert(this[this.current].text);
              this.clear();
            }
        }
      }
    };

    return Instructions;

  })();
});

// Generated by CoffeeScript 1.5.0-pre
