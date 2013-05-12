define [
  'core/placetiles'
], (placeTiles) ->
  
  class MoveTile
    BORDERSIZE  : 4
    BORDERSIZE_ : 0.25
    CELLSIZE    : 32
    size        : null
    x           : 0
    y           : 0
    w           : 1
    h           : 1
    
    transposeOrientation : ->
      [_w,_h] = [@w,@h]
      @w = _h
      @h = _w
    
    containsPoint : (x,y) ->
      return ( @x < x < @x+@CELLSIZE*@w ) and ( @y < y < @y+@CELLSIZE*@h )
    
    
    draw : ->
      atom.context.lineWidth    = 2
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
          
          atom.context.fillStyle = '#abc'
          
          atom.context.fillRect(x, y, w, h)
          atom.context.strokeRect(x, y, w, h)
          
          atom.context.fillStyle = '#789'
          atom.context.beginPath()
          
          atom.context.arc(cx, cy, 8, 0, 2*Math.PI, true)
          atom.context.fill()
          atom.context.stroke()
      
      # draw bold outline!
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
        if t.x < minX then minX = t.x
        if t.y < minY then minY = t.y
        
        if t.x+t.w > maxX then maxX = t.x+t.w
        if t.y+t.h > maxY then maxY = t.y+t.h

      @user.layout.x  = minX
      @user.layout.y  = minY
      @user.layout.bx = maxX
      @user.layout.by = maxY
    
    verifyLayoutValid : ->
      layout = ( 0 for i in [0...(@user.layout.bx-@user.layout.x)*(@user.layout.by-@user.layout.y)])
      for t in @tiles
        t.
    
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
        total : []
      mouseOffset :
        x : 0
        y : 0

    mode :
      current : 'select'

      select : (dt) ->
        if atom.input.down('mouseleft') and @findTile()
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
        
        else
          # check overall correctness of layout
          
        @user.lastClick += dt
                      
      move : (dt) ->
        if atom.input.released('mouseleft') and @user.tile?
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
    
      atom.input.bind atom.button.LEFT, 'mouseleft'
    
    
    checkNoOverlap : ->
      #min
      #for 
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])
    
    draw : ->
      atom.context.clear()
      t.draw() for t in @tiles