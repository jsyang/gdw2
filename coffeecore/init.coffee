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
  }, ->
    loaded.sfx = true
    isPreloadComplete()
  )
  
  return
