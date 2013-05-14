define [
  'core/placetiles'
], (placeTiles) ->
  
  CELLSIZE = 32
  
  COLORS =
    RED   : 1
    BLACK : 2
  
  class MoveTile
    BORDERSIZE        : 4
    BORDERSIZE_       : 0.25
    CELLSIZE          : CELLSIZE
    size              : null
    x                 : 0
    y                 : 0
    w                 : 1
    h                 : 1
    # tile coords relative to user.layout
    lx                : 0   
    ly                : 0
    
    invalidPlacement  : true
    
    cells             : null
    
    transposeOrientation : ->
      [_w,_h] = [@w,@h]
      @w = _h
      @h = _w
    
    containsPoint : (x,y) ->
      return ( @x < x < @x+@CELLSIZE*@w ) and ( @y < y < @y+@CELLSIZE*@h )
    
    lockOrientation : -> @cells = (0 for i in [0...@w*@h])
    
    getInnerCell : (x,y) -> return @cells[@w*y+x]
    
    getOuterCell : (x,y) -> return @getInnerCell(x-@lx,y-@ly)
    
    setInnerCell : (x,y,v) -> return @cells[@w*y+x] = v
    
    setOuterCell : (x,y,v) -> return @setInnerCell(x-@lx,y-@ly,v)
    
    draw : ->
      ac = atom.context
    
      ac.lineWidth    = 2
      
      if @invalidPlacement
        ac.strokeStyle  = '#a99'
      else
        ac.strokeStyle  = '#999'
        
      
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
            ac.fillStyle = '#dbc'
          else
            ac.fillStyle = '#abc'
            
          
          ac.fillRect(x, y, w, h)
          ac.strokeRect(x, y, w, h)
          
          if @invalidPlacement
            ac.fillStyle = '#a89'
          else
            if @cells? and @cells[@w*j+i] > 0
              if @cells[@w*j+i] is 1
                ac.fillStyle = '#b32'
              else
                ac.fillStyle = '#222'
            else 
              ac.fillStyle = '#789'
          
          ac.beginPath()
          
          ac.arc(cx, cy, 8, 0, 2*Math.PI, true)
          ac.fill()
          ac.stroke()
      
      # draw bold outline!
      if @invalidPlacement
        ac.strokeStyle  = '#500'
      else
        ac.strokeStyle  = '#000'
        
      ac.lineWidth    = @BORDERSIZE
      ac.strokeRect(@x+@BORDERSIZE_+1, @y+@BORDERSIZE_+1, @w*@CELLSIZE-@BORDERSIZE+2, @h*@CELLSIZE-@BORDERSIZE+2)
    
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
        
        
  
  class Button
    x : 0
    y : 0
    w : 0
    h : 0
    
    containsPoint : (x,y) ->
      return ( @x <= x <= @x+@w ) and ( @y <= y <= @y+@h )
    
    state : 'up'
    
    color :
      pressed : '#b00'
      up      : '#f00'
    
    draw : ->
      ac = atom.context
      ac.lineWidth    = 2
      ac.strokeStyle  = '#111'
      ac.fillStyle  = @color[@state]
      ac.fillRect(@x, @y, @w, @h)
      ac.strokeRect(@x, @y, @w, @h)
      
      
    constructor : (params) ->
      @[k] = v for k, v of params
    
    
    
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
      
      @user.layout.array = layout
      
      return true
      
    
    findUIThing : (thingType) ->
      mx = atom.input.mouse.x
      my = atom.input.mouse.y
      
      switch thingType
        when 'tiles'
          for t in @tiles
            if t.containsPoint(mx, my)
              @user.tile = t
              @user.mouseOffset.x = mx - t.x
              @user.mouseOffset.y = my - t.y
              return true
      
        when 'buttons'
          for k,v of @buttons
            if v.containsPoint(mx, my)
              @user.lastButton = v
              return true
          @user.lastButton = null
      
      false
    
    translateMouseToLayout : ->
      # tile coords. not pixel coords
      return {
        x : ((atom.input.mouse.x>>5) - @user.layout.x<<5) >> 5
        y : ((atom.input.mouse.y>>5) - @user.layout.y<<5) >> 5
      }
    
    user :
      COLORS : [ null, 'red', 'black' ]
      
      color : 1
    
      lastClick   : 0
      lastButton  : null
      lastTile    : null     
      tile        : null
      layout    :
        array : []
        # units for these coords are in tiles, not pixels
        x   : 0   
        y   : 0
        bx  : 0
        by  : 0
      mouseOffset :
        x : 0
        y : 0

    mode :
      current : 'select'

      play : (dt) ->
        if (atom.input.pressed('touchfinger') or atom.input.pressed('mouseleft'))
          if @findUIThing('tiles')
            mouse = @translateMouseToLayout()
            if @user.tile.getOuterCell(mouse.x, mouse.y)
              # already played here. illegal move
            else
              @user.tile.setOuterCell(mouse.x, mouse.y, @user.color)
              @user.color++
              if @user.color > 2 then @user.color = 1
              
          atom.playSound('crack')
      
      select : (dt) ->
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
        
          if @findUIThing('tiles')
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
        
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft'))
          if @findUIThing('buttons')
            atom.playSound('drop')
            @triggers[@user.lastButton.clicked].apply(@) if @user.lastButton.clicked?
            
      move : (dt) ->
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft')) and @user.tile?
          # dropped
          @user.lastClick = 0
          @mode.current = 'select'
          @user.tile.x = 32*Math.round(@user.tile.x * 0.03125)
          @user.tile.y = 32*Math.round(@user.tile.y * 0.03125)
          atom.playSound('drop')
          
          if @verifyLayoutValid() is true
            @triggers.enablestartbutton.call(@)
          else
            @triggers.disablestartbutton.call(@)
          
        else
          @user.lastClick += dt
          @user.tile.x = atom.input.mouse.x - @user.mouseOffset.x
          @user.tile.y = atom.input.mouse.y - @user.mouseOffset.y
    
    triggers :
      removestartbutton : ->
        b = @buttons.start
        if b?
          delete @buttons.start
          
      enablestartbutton : ->
        b = @buttons.start
        if b?
          b.color =
            pressed : '#0a0'
            up      : '#3e8'
          b.clicked = 'startgame'
        
      disablestartbutton : ->
        b = @buttons.start
        if b?
          b.color =
            pressed : '#0a0'
            up      : '#aeb'
          b.clicked = null
        
      startgame : ->
        (
          t.lockOrientation()
          t.lx = (t.x>>5) - @user.layout.x
          t.ly = (t.y>>5) - @user.layout.y
        ) for t in @tiles
        @verifyLayoutValid()
        @triggers.removestartbutton.call(@)
        @mode.current = 'play'
    
    tiles : []
    
    buttons :
      start : new Button({
        x : atom.width - 100
        y : 20
        w : 80
        h : 80
        clicked : null
        color :
          pressed : '#0a0'
          up : '#3e8'
      })
    
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
      v.draw() for k,v of @buttons