
define(['core/util', 'core/atom', 'core/game'], function(_util, _atom, Kulami) {
  var isPreloadComplete, loaded, startGame;
  startGame = function() {
    window.q = new Kulami();
    return q.run();
  };
  loaded = {
    gfx: false,
    sfx: false
  };
  isPreloadComplete = function() {
    if (loaded.gfx && loaded.sfx) {
      startGame();
      return true;
    } else {
      return false;
    }
  };
  atom.preloadImages({
    cell_: 'cell_.png',
    cell_red: 'cell_red.png',
    cell_black: 'cell_black.png',
    button_random: 'button_random.png',
    button_help: 'button_help.png',
    button_play: 'button_play.png'
  }, function() {
    loaded.gfx = true;
    return isPreloadComplete();
  });
  atom.preloadSounds({
    crack: 'crack.mp3',
    pick: 'pick.mp3',
    drop: 'drop.mp3',
    invalid: 'invalid.wav',
    valid: 'valid.wav',
    gamerules1: 'gamerules1.mp3',
    gamerules2: 'gamerules2.mp3',
    gamerules3: 'gamerules3.mp3',
    gamerules4: 'gamerules4.mp3'
  }, function() {
    loaded.sfx = true;
    return isPreloadComplete();
  });
});

// Generated by CoffeeScript 1.5.0-pre
