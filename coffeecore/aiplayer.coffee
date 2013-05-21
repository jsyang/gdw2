define ->
  class AIPlayer
    
    color : 2
    
    constructor : (params) ->
      @[k] = v for k, v of params
      if !(@game?) then throw new Error 'no game reference was given to create the state object!'
      
    makeMove : ->
      move = @game.aistate.findBestMove()
      @game.user.tile = move.tile
      @game.triggers.movemade.call(@game, move)
      console.log('ai plays', [move.x,move.y], 'with tile', move.tile)
      
    makeSnarkyRemark : ->
      # todo