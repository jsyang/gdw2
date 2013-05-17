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
    
    NEUTRAL_GAMERULES1 :
      text  : 'Kulami\n\nThis game is won by scoring.\nA player who owns the most cells wins.\nOn each turn, a player places a marble in an empty spot on a tile.'
      audio : null
      time  : 0
      
    NEUTRAL_GAMERULES2 :
      text  : 'A tile (and its entire collection of cells) is owned by a player when the majority of its marbles are that player\'s color.'
      audio : null
      time  : 0

    NEUTRAL_GAMERULES3 :
      text  : 'On each turn, a player places a marble in an empty spot on a tile that does not contain the marble placed in the previous turn.\nThe move is legal only if it lies on the same row or column as the last turn.'
      audio : null
      time  : 0
      
    NEUTRAL_GAMERULES4 :
      text  : 'The game ends when a player has no legal moves left on their turn.'
      audio : null
      time  : 0
    
    
    BAD_REDSTURN :
      text  : 'It\'s Red\'s turn.'
      audio : null
      time  : 0
    
    BAD_BLACKSTURN :
      text  : 'It\'s Black\'s turn.'
      audio : null
      time  : 0 # milliseconds
    
    timer : 600
    type : 'text'
    current : 'NEUTRAL_BOARDSETUP'
    
    game : null # ref to parent game
    
    constructor : (params) ->
      @[k] = v for k, v of params
      
      # add HELP sequence
      HELP : [
        @NEUTRAL_GAMERULES1
        @NEUTRAL_GAMERULES2
        @NEUTRAL_GAMERULES3
        @NEUTRAL_GAMERULES4
      ]
    
    clear : -> @current = null
    
    set : (params)->
      if params?
        @current  = params.name
        @timer    = @[@current].time
        @type     = if params.type? then params.type else 'text'
    
    draw : ->
      if @current?
        switch @type
          when 'text'
            if @timer > 0
              ac = atom.context
              ac.font = 'bold 20px Helvetica';
              ac.fillStyle = '#222'
              
              text = @[@current].text.split('\n')
              i = 0
              for l in text
                ac.fillText(l.toUpperCase(), 10, atom.height-(20*(text.length-i)))
                i++
              @timer--
          when 'alert'
            if @timer > 0
              alert(@[@current].text)
              @clear()
            
          
    
      return