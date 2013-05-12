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
    
    containsPoint : (x,y) ->
      return ( @x < x < @x+@CELLSIZE*@w ) and ( @y < y < @y+@CELLSIZE*@h )
    
    
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

    findTile : ->
      mx = atom.input.mouse.x
      my = atom.input.mouse.y
      for t in @tiles
        if t.containsPoint(mx, my)
          @user.tile = t
          @user.mouseOffset.x = mx - t.x
          @user.mouseOffset.y = my - t.y 
          return true
      false
      
    user :
      tile : null
      mouseOffset :
        x : 0
        y : 0

    mode :
      current : 'select'

      select : ->
        if atom.input.down('mouseleft') and @findTile()
          @mode.current = 'move'
          
      move : ->
        if atom.input.released('mouseleft') and @user.tile?
          @mode.current = 'select'
          @user.tile.x = 32*Math.round(@user.tile.x * 0.03125)
          @user.tile.y = 32*Math.round(@user.tile.y * 0.03125)
          
        else
          @user.tile.x = atom.input.mouse.x - @user.mouseOffset.x
          @user.tile.y = atom.input.mouse.y - @user.mouseOffset.y
    
    
    tiles : []
      
    constructor : ->
      tileList =  # The full list for kulami.
        '3x2' : 4
        '2x2' : 5
        '3x1' : 4
        '2x1' : 4
      
      makeTile = (size) =>
        @tiles.push(
          new MoveTile({
            size
            x     : $$.R(1,300)
            y     : $$.R(1,300)
          })
        )
      
      ( makeTile(k) for i in [0...v] ) for k,v of tileList
    
      atom.input.bind atom.button.LEFT, 'mouseleft'
    
    
    update : (dt) ->
      @mode[@mode.current].apply(@)
    
    draw : ->
      atom.context.clear()
      t.draw() for t in @tiles