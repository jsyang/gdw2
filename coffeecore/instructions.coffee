define ->
  class Instructions
    
    # each string is prefaced with a mood so the key for it is searchable
    
    NEUTRAL_BOARDSETUP :
      text  : 'Construct board layout.\n\nDrag the tiles to form a board of \nnon-overlapping tiles. Overlapped\ntiles are shown in red. Double click \na tile to change its rotation.'
      audio : null
      time  : Infinity # game cycles
    
    BAD_BOARDINVALID :
      text  : 'Illegal board layout!'
      audio : null
      time  : 0
    
    BAD_MOVEINVALID :
      text  : 'Illegal move!'
      audio : null
      time  : 100
    
    NEUTRAL_GAMERULES1 :
      text  : '[1/5] This game is won by scoring. The\nplayer who owns the most cells wins.\nOn each turn, a player places a marble\non an empty spot on a tile.'
      audio : 'gamerules1'
      time  : 700
      
    NEUTRAL_GAMERULES2 :
      text  : '[2/5] A player owns a tile when his\nmarbles take up a majority of the\ncells on the tile.'
      audio : 'gamerules2'
      time  : 400
      
    NEUTRAL_GAMERULES3 :
      text  : '[3/5] A player\'s score is the sum of\nthe cells in owned tiles.'
      audio : null # todo
      time  : 400

    NEUTRAL_GAMERULES4 :
      text  : '[4/5] Players take turns placing one\nmarble (per turn) in an empty cell on\na tile that doesn\'t contain the last\nmove.\nA move is legal only if it lies on the\nsame row or column as the last\nmarble played.'
      audio : 'gamerules3'
      time  : 900
      
    NEUTRAL_GAMERULES5 :
      text  : '[5/5] The game ends when a player has\nno legal moves left on their turn.'
      audio : 'gamerules4'
      time  : 300
    
    NEUTRAL_REDSTURN :
      text  : 'Red\'s turn.'
      audio : null
      time  : Infinity
    
    NEUTRAL_BLACKSTURN :
      text  : 'Black\'s turn.'
      audio : null
      time  : Infinity
      
    NEUTRAL_GAMEOVER :
      text  : 'Game over!'
      audio : null
      time  : Infinity
    
    current       : 'NEUTRAL_BOARDSETUP'
    type          : 'text'
    timer         : Infinity
    sequenceIndex : null
    
    game : null # ref to parent game
    
    constructor : (params) ->
      @[k] = v for k, v of params
      
      # add HELP sequence
      @HELP = [
        @NEUTRAL_GAMERULES1
        @NEUTRAL_GAMERULES2
        @NEUTRAL_GAMERULES3
        @NEUTRAL_GAMERULES4
        @NEUTRAL_GAMERULES5
      ]
    
    clear : ->
      @current = null
    
    set : (params)->
      if params?
        @current        = params.name if params.name
        if @[@current] instanceof Array
          item          = @[@current][0]
        else
          item          = @[@current]
        @timer          = if params.time? then params.time else item.time
        @type           = if params.type? then params.type else 'text'
        @sequenceIndex  = 0
    
    prevInSequence : ->
      @sequenceIndex--
      if @sequenceIndex < 0
        @sequenceIndex = 0
        @game.triggers.disablehelprewind.call(@game)
      
      if @sequenceIndex is 0
        @game.triggers.disablehelprewind.call(@game)
        
      @timer = @[@current][@sequenceIndex].time+1
      atom.stopAllSounds()
        
    
    nextInSequence : ->
      @sequenceIndex++
      if @sequenceIndex < @[@current].length
        @timer = @[@current][@sequenceIndex].time
        @game.triggers.enablehelprewind.call(@game)
      else
        # We're done!
        atom.stopAllSounds()
        @clear()
        @game.triggers.showwhosturn.call(@game)
        
    draw : ->
      if @current?
        switch @type
          when 'text'
            if @timer > 0
              
              ac = atom.context
              ac.font = 'bold 20px Helvetica';
              ac.fillStyle = '#222'
              
              isSequence = @[@current] instanceof Array
              
              if isSequence
                item = @[@current][@sequenceIndex]
              else
                item = @[@current]
                
              text  = item.text.split('\n')
              audio = item.audio
                
                
              if audio? and @timer is item.time
                atom.stopAllSounds()
                atom.playSound(audio)
              
              i = 0
              for l in text
                ac.fillText(l.toUpperCase(), 10, atom.height-(20*(text.length-i)))
                i++
                
              @timer--
              
              # Play these messages consecutively
              if isSequence and @timer is 0
                @nextInSequence()
              
          when 'alert'
            if @timer > 0
              alert(@[@current].text)
              @clear()
            
          
    
      return