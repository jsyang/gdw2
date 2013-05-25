define ->
  class AIPlayer
    
    color : 2
    
    constructor : (params) ->
      @[k] = v for k, v of params
      if !(@game?) then throw new Error 'no game reference was given to create the state object!'
      
    makeMove : ->
      move = @game.aistate.findBestMove()
      # Try again with non-optimal legal moves.
      if !(move.tile?) then move = @game.aistate.findBestMove(true)
      
      @game.user.tile = move.tile
      @game.triggers.movemade.call(@game, move)
      
      #console.log('ai plays', [move.x,move.y], 'with tile', move.tile)
      
    makeSnarkyRemark : (type) ->
      switch type
        when 'GOOD'
          taunt = $$.WR({
            'r_excellent' : 2
            'r_good'      : 3
            'r_haha'      : 2
            'r_damn'      : 1
            'r_damnit'    : 1
            'silence'     : 4
          })
        when 'BAD'
          taunt = $$.WR({
            'r_haha'      : 4
            'r_slow'      : 2
            'r_fate'      : 1
            'r_disturb'   : 1
            'silence'     : 3
          })
        when 'NEUTRAL'
          taunt = $$.WR({
            'r_slow'      : 1
            'r_longenough': 1
            'r_haha'      : 2
            'r_damn'      : 1
            'silence'     : 4
          })
      
      console.log('taunt attempt:', taunt)
      
      if taunt? and taunt != 'silence'
        if $$.r() < 0.2 # 20% chance of playing a taunt ontop of existing probability.
          atom.playSound(taunt)