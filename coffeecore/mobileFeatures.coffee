define [
  'core/mobileDetect'
], (detectMobile) ->
  
  if window.isMobile?
  
    # mobile sound
    require ['howler'], (l) ->
      mobileSound = new Howl({
        urls : ['sfx/sprite.mp3']
        sprite :
          crack       : [0,534]
          pick        : [32670,145]
          drop        : [569,296]
          invalid     : [32520,151]
          valid       : [32839,198]
          gamerules1  : [1022,9056]
          gamerules2  : [10263,5155]
          gamerules3  : [15465,13050]
          gamerules4  : [28514,3994]  
      })
      
      atom.playSound = -> mobileSound.play.apply(mobileSound, arguments)
      return
    
    # mobile orientation change
    window.onorientationchange = ->
      window.onresize()
      
      if window.orientation is 0
        window.game.triggers.verticalorientation.call(window.game)
      else
        window.game.triggers.horizontalorientation.call(window.game)
      return
  
  return