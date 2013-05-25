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
          
          # Fast-forwarding through these will give an echo
          #gamerules1  : [1022,9056]
          #gamerules2  : [10263,5155]
          #gamerules3  : [15465,13050]
          #gamerules4  : [28514,3994]
          
          r_damn        : [33215,572]
          r_damnit      : [34076,749]
          r_disturbing  : [34996,2986]
          r_excellent   : [38231,1086]
          r_fate        : [39448,2079]
          r_good        : [41527,1034]
          r_haha        : [42561,883]
          r_hmm         : [43663,503]
          r_longenough  : [44316,1498]
          r_slow        : [46068,1739]
      })
      
      atom.playSound = -> mobileSound.play.apply(mobileSound, arguments)
      atom.stopAllSounds = -> mobileSound.stop.apply(mobileSound)
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