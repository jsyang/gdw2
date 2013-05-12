define [
  'core/placetiles'
], (placeTiles) ->
  
  class MoveTile
    CELLSIZE  : 32
    size      : null
    x         : 0
    y         : 0
    w         : 1
    h         : 1
    
    transposeOrientation : false
    
    draw : ->
      if @transposeOrientation
      else

        for j in [0...@h]
          for i in [0...@w]
            [x,y,w,h,cx,cy] = [
              @x+@CELLSIZE*i
              @y+@CELLSIZE*j
              @CELLSIZE
              @CELLSIZE
              @x+@CELLSIZE*i + @CELLSIZE*0.5
              @y+@CELLSIZE*j + @CELLSIZE*0.5
            ]
            
            atom.context.fillStyle = '#abc'
            
            atom.context.fillRect(x, y, w, h)
            atom.context.strokeRect(x, y, w, h)
            
            atom.context.fillStyle = '#789'
            atom.context.beginPath()
            console.log(cx,cy)
            atom.context.arc(cx, cy, 12, 0, 2*Math.PI, true)
            atom.context.fill()
            atom.context.stroke()
            
            
    
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
        
        [@w, @h] = [parseInt(@w), parseInt(@h)]
        
  
  class Kulami extends atom.Game
    mode : 'placetiles'
    tiles : []
    constructor : ->
      
      makeTile = ->
        w = $$.R(1,3)
        if w is 3
          h = $$.R(1,2)
        else if w is 1
          h = $$.R(2,3)
        else
          h = $$.R(1,3)
        
        new MoveTile({
          size  : "#{w}x#{h}"
          x     : $$.R(1,300)
          y     : $$.R(1,300)
        })
      
      @tiles = (makeTile() for i in [0...$$.R(1,10)])
    
    draw : ->
      t.draw() for t in @tiles