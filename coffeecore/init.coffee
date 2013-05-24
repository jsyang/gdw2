define [
  'core/util'
  'core/atom'
  'core/game'
], (_util, _atom, Kulami) ->

  startGame = ->
    window.q = new Kulami()
    q.run()
  
  loaded =
    gfx : false
    sfx : false
    
  isPreloadComplete = ->
    if loaded.gfx and loaded.sfx
      startGame()
      true
    else
      false
    
  atom.preloadImages({
    cell_       : 'cell_.png'
    cell_red    : 'cell_red.png'
    cell_black  : 'cell_black.png'
    
    button_random : 'button_random.png'
    button_help : 'button_help.png'
    button_play : 'button_play.png'
    button_fastforward : 'button_fastforward.png'
    button_rewind : 'button_rewind.png'
    button_restart : 'button_restart.png'
  }, ->
    loaded.gfx = true
    isPreloadComplete()
  )
  
  atom.preloadSounds({
    crack       : 'crack.mp3'
    pick        : 'pick.mp3'
    drop        : 'drop.mp3'
    invalid     : 'invalid.wav'
    valid       : 'valid.wav'
    gamerules1  : 'gamerules1.mp3'
    gamerules2  : 'gamerules2.mp3'
    gamerules3  : 'gamerules3.mp3'
    gamerules4  : 'gamerules4.mp3'
    
    r_damn        : 'remarks/damn.wav'
    r_damnit      : 'remarks/damnit.wav'
    r_disturbing  : 'remarks/disturb.wav'
    r_excellent   : 'remarks/excellent.wav'
    r_fate        : 'remarks/fate.wav'
    r_good        : 'remarks/good.wav'
    r_haha        : 'remarks/haha.wav'
    r_hmm         : 'remarks/hmm.wav'
    r_longenough  : 'remarks/longenough.wav'
    r_slow        : 'remarks/slow.wav'
    
    
  }, ->
    loaded.sfx = true
    isPreloadComplete()
  )
  
  return
