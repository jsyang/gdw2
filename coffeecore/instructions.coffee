define ->
  class Instructions
    
    NEUTRAL_BOARDSETUP :
      text  : 'Drag the tiles to form a board.\nA illegaly placed tile becomes translucent.\nHit the GO button to start the game.'
      audio : null
      time  : 0 # milliseconds
    
    BAD_BOARDINVALID :
      text  : 'Illegal board layout!'
      audio : null
      time  : 0 # milliseconds
    
    NEUTRAL_GAMERULES1 :
      text  : 'This game is won by scoring.\nA player who owns the most cells wins.\nOn each turn, a player places a marble in an empty spot on a tile.'
      audio : null
      time  : 0 # milliseconds
      
    NEUTRAL_GAMERULES2 :
      text  : 'A tile (and its entire collection of cells) is owned by a player when the majority of its marbles are that player\'s color.'
      audio : null
      time  : 0 # milliseconds

    NEUTRAL_GAMERULES3 :
      text  : 'On each turn, a player places a marble in an empty spot on a tile that does not contain the marble placed in the previous turn.\nThe move is legal only if it lies on the same row or column as the last turn.'
      audio : null
      time  : 0 # milliseconds
      
    NEUTRAL_GAMERULES4 :
      text  : 'The game ends when a player has no legal moves left on their turn.'
      audio : null
      time  : 0 # milliseconds
    
    
    BAD_REDSTURN :
      text  : 'It\'s Red\'s turn.'
      audio : null
      time  : 0 # milliseconds
    
    BAD_BLACKSTURN :
      text  : 'It\'s Black\'s turn.'
      audio : null
      time  : 0 # milliseconds
    
    type : 'text'
    
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
        
    draw : ->
      