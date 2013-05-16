define [
  'core/util'
  'core/atom'
  'core/game'
], (_util, _atom, Kulami) ->

  startGame = ->
    (new Kulami()).run()
  
  loaded =
    gfx : true #false
    sfx : false
    
  isPreloadComplete = ->
    if loaded.gfx and loaded.sfx
      startGame()
      true
    else
      false
  
  
  # No GFX yet.
  #atom.preloadImages({
  #  ball : 'ball.png'
  #}, ->
  #  loaded.gfx = true
  #  isPreloadComplete()
  #)
  
  atom.preloadSounds({
    crack : 'crack.mp3'
    pick  : 'pick.mp3'
    drop  : 'drop.mp3'
  }, ->
    loaded.sfx = true
    isPreloadComplete()
  )
  
  return
