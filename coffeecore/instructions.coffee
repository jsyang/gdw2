define ->
  class Instructions
    
    # each string is prefaced with a mood so the key for it is searchable
    
    NEUTRAL_BOARDSETUP :
      text  : 'Drag the tiles to form a board of \nnon-overlapping tiles. Overlapped\ntiles are outlined in red.'
      audio : null
      time  : 1000 # game cycles
    
    BAD_BOARDINVALID :
      text  : 'Illegal board layout!'
      audio : null
      time  : 0
    
    BAD_MOVEINVALID :
      text  : 'Illegal move!'
      audio : null
      time  : 100
    
    NEUTRAL_GAMERULES1 :
      text  : 'This game is won by scoring.\nThe player who owns the most cells wins.\nOn each turn, a player places a marble\non an empty spot on a tile.'
      audio : 'gamerules1'
      time  : 700
      
    NEUTRAL_GAMERULES2 :
      text  : 'A player owns a tile when his marbles\ntake up a majority of the cells on the tile.'
      audio : 'gamerules2'
      time  : 400

    NEUTRAL_GAMERULES3 :
      text  : 'Players take turns placing one marble (per turn)\nin an empty cell on a tile that doesn\'t contain\nthe last move.\nA move is legal only if it lies on the same row\nor column as the last marble played.'
      audio : 'gamerules3'
      time  : 900
      
    NEUTRAL_GAMERULES4 :
      text  : 'The game ends when a player has\nno legal moves left on their turn.'
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
    
    current       : 'NEUTRAL_BOARDSETUP'
    type          : 'text'
    timer         : 600
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
    
    nextInSequence : ->
      @sequenceIndex++
      if @sequenceIndex < @[@current].length
        @timer = @[@current][@sequenceIndex].time
      else
        @clear()
        
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