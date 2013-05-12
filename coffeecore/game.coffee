define [
  'core/placetiles'
], (placeTiles) ->
  
  CELLSIZE = 32
  
  class MoveTile
    size  : null
    x     : 0
    y     : 0
    w     : 1
    h     : 1
    constructor : (params) ->
      @[k] = v for k, v of params
      
      if @size?
        sides = @size.split('x')
        if sides[0] > sides[1]
          @w = sides[0]
          @h = sides[1]
        else
          @w = sides[1]
          @h = sides[0]
      
        
  
  class Kulami extends atom.Game
    mode : 'placetiles'
    tiles : []
    constructor : ->
      
      
      @tiles = [
        new MoveTile({ size: '2x2' })
        new MoveTile({ size: '3x1' })
        new MoveTile({ size: '2x1' })
        new MoveTile({ size: '3x2' })
      ]
    
    draw : ->
      atom.context