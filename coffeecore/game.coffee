define [
  'core/placetiles'
], (placeTiles) ->
  
  CELLSIZE = 32
  
  class MoveTile
    BORDERSIZE        : 4
    BORDERSIZE_       : 0.25
    CELLSIZE          : CELLSIZE
    size              : null
    x                 : 0
    y                 : 0
    w                 : 1
    h                 : 1
    invalidPlacement  : true
    
    transposeOrientation : ->
      [_w,_h] = [@w,@h]
      @w = _h
      @h = _w
    
    containsPoint : (x,y) ->
      return ( @x < x < @x+@CELLSIZE*@w ) and ( @y < y < @y+@CELLSIZE*@h )
    
    
    draw : ->
      atom.context.lineWidth    = 2
      
      if @invalidPlacement
        atom.context.strokeStyle  = '#a99'
      else
        atom.context.strokeStyle  = '#999'
        
      
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
          
          if @invalidPlacement
            atom.context.fillStyle = '#dbc'
          else
            atom.context.fillStyle = '#abc'
            
          
          atom.context.fillRect(x, y, w, h)
          atom.context.strokeRect(x, y, w, h)
          
          if @invalidPlacement
            atom.context.fillStyle = '#a89'
          else
            atom.context.fillStyle = '#789'
          
          atom.context.beginPath()
          
          atom.context.arc(cx, cy, 8, 0, 2*Math.PI, true)
          atom.context.fill()
          atom.context.stroke()
      
      # draw bold outline!
      if @invalidPlacement
        atom.context.strokeStyle  = '#500'
      else
        atom.context.strokeStyle  = '#000'
        
      atom.context.lineWidth    = @BORDERSIZE
      atom.context.strokeRect(@x+@BORDERSIZE_+1, @y+@BORDERSIZE_+1, @w*@CELLSIZE-@BORDERSIZE+2, @h*@CELLSIZE-@BORDERSIZE+2)
    
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
    
    getLayoutOrigin : ->
      minX  = Infinity
      maxX  = 0
      minY  = Infinity
      maxY  = 0
      
      for t in @tiles
        if (t.x>>5) < minX then minX = t.x>>5
        if (t.y>>5) < minY then minY = t.y>>5
        
        if (t.x>>5)+t.w > maxX then maxX = (t.x>>5) + t.w
        if (t.y>>5)+t.h > maxY then maxY = (t.y>>5) + t.h

      @user.layout.x  = minX
      @user.layout.y  = minY
      @user.layout.bx = maxX
      @user.layout.by = maxY
      
      #console.log(
      #  @user.layout.x,
      #  @user.layout.y, 
      #  @user.layout.bx,
      #  @user.layout.by,
      #  minX,
      #  maxX,
      #  minY,
      #  maxY
      #)
      #
    verifyLayoutValid : ->
      @getLayoutOrigin()
      layout = ( 0 for i in [0...(@user.layout.bx+1)*(@user.layout.by+1)] )
      for t in @tiles
        minX = @user.layout.x + (t.x>>5)
        minY = @user.layout.y + (t.y>>5)
        for y in [0...t.h]
          for x in [0...t.w]
            layout[(minY+y)*@user.layout.bx + (minX+x)]++
            if layout[(minY+y)*@user.layout.bx + (minX+x)] > 1
              t.invalidPlacement = true
              return false
        t.invalidPlacement = false
      return true
      
    
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
      lastClick : 0
      lastTile  : null     
      tile      : null
      layout    :
        x   : 0
        y   : 0
        bx  : 0
        by  : 0
      mouseOffset :
        x : 0
        y : 0

    mode :
      current : 'select'

      select : (dt) ->
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft')) and @findTile()
          # double click to change orientation
          if @user.lastTile is @user.tile and @user.lastClick < 0.3
            @user.tile.transposeOrientation()
            atom.playSound('drop')
            @user.lastTile = null
            
          else
            @user.lastClick = 0
            @mode.current = 'move'
            @user.lastTile = @user.tile
            atom.playSound('pick')
             
        @user.lastClick += dt
                      
      move : (dt) ->
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft')) and @user.tile?
          # dropped
          @user.lastClick = 0
          @mode.current = 'select'
          @user.tile.x = 32*Math.round(@user.tile.x * 0.03125)
          @user.tile.y = 32*Math.round(@user.tile.y * 0.03125)
          atom.playSound('drop')
          
          @verifyLayoutValid()
          
        else
          @user.lastClick += dt
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
    
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])
    
    draw : ->
      atom.context.clear()
      t.draw() for t in @tiles