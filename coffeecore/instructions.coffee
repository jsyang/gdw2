define ->
  class Instructions
    
    NEUTRAL_BOARDSETUP :
      text  : 'Drag the tiles to form a board.\nA illegaly placed tile becomes translucent.\nHit the GO button to start the game.'
      audio : null
    
    BAD_BOARDINVALID :
      text  : 'Illegal board layout!'
      audio : null
    
    NEUTRAL_GAMERULES1 :
      text  : 'This game is won by scoring.\nA player who owns the most cells wins.\nOn each turn, a player places a marble in an empty spot on a tile.'
      audio : null
      
    NEUTRAL_GAMERULES2 :
      text  : 'A tile (and its entire collection of cells) is owned by a player when the majority of its marbles are that player\'s color.\nOn each turn, a player places a marble in an empty spot on a tile.'
      audio : null
      
    type : 'text'
    
    game : null # ref to parent game
    
    constructor : (params) ->
      @[k] = v for k, v of params
      
    