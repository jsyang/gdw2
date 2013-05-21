define ->
  class MoveTile
    BORDERSIZE        : 4
    BORDERSIZE_       : 0.25
    CELLSIZE          : 32 # or 1<<5
    size              : null
    
    # If a player controls this tile, how much does their score go up?
    score             : 0 
    
    # in pixels
    x                 : 0
    y                 : 0
    
    # in tiles
    w                 : 1
    h                 : 1
    
    # tile coords relative to user.layout
    lx                : 0   
    ly                : 0
    
    rotation          : 0
    
    invalidPlacement  : true
    
    cells             : null
    
    transposeOrientation : ->
      [_w,_h] = [@w,@h]
      @w = _h
      @h = _w
    
    containsPoint : (x,y) -> # in pixels
      return ( @x <= x < @x+@CELLSIZE*@w ) and ( @y <= y < @y+@CELLSIZE*@h )
    
    lockOrientation : ->
      @score = @w*@h
      @cells = (0 for i in [0...@score])
    
    # in tiles
    getInnerCell : (x,y) -> return @cells[@w*y+x]
    getOuterCell : (x,y) -> return @getInnerCell(x-@lx,y-@ly)
    setInnerCell : (x,y,v) -> return @cells[@w*y+x] = v
    setOuterCell : (x,y,v) -> return @setInnerCell(x-@lx,y-@ly,v)
    
    getCentroid : ->
      return {
        x : @x + @w*@CELLSIZE*0.5
        y : @y + @h*@CELLSIZE*0.5
      }
    
    draw : ->
      
      ac = atom.context
  
      ac.save()
      c = @getCentroid()
      ac.translate(c.x, c.y)
      rotationMagnitude = Math.abs(@rotation)
      if rotationMagnitude > 0
        @rotation *= 0.6
        if rotationMagnitude < 0.001 then @rotation = 0
      ac.rotate(@rotation) unless @rotation is 0

      ac.lineWidth = 2
      
      for j in [0...@h]
        for i in [0...@w]
          [x,y,w,h,cx,cy] = [
            @CELLSIZE*(i-@w*0.5)
            @CELLSIZE*(j-@h*0.5)
            @CELLSIZE
            @CELLSIZE
            @CELLSIZE*(i-@w*0.5) + @CELLSIZE*0.5
            @CELLSIZE*(j-@h*0.5) + @CELLSIZE*0.5
          ]
          
          #ac.globalAlpha = if @invalidPlacement then 0.4 else 1

          if @cells? and @cells[@w*j+i] > 0
            if @cells[@w*j+i] is 1
              # red marble
              img = atom.gfx.cell_red
            else
              # black marble
              img = atom.gfx.cell_black
          else
            img = atom.gfx.cell_
            
          ac.drawImage(img, x, y)

      # draw bold outline!
      if @invalidPlacement
        strokeStyleDark   = '#f00'
        strokeStyleLight  = '#f88'
      else
        strokeStyleDark   = '#333'
        strokeStyleLight  = '#88f'
        
      [x,y] = [
        @CELLSIZE*(-@w*0.5)
        @CELLSIZE*(-@h*0.5)
      ]
      [lx,ly] = [
        x+@BORDERSIZE_+1
        y+@BORDERSIZE_+1
      ]
      ac.strokeStyle  = strokeStyleDark
      ac.lineWidth    = @BORDERSIZE
      ac.lineJoin     = 'round'
      ac.strokeRect(lx, ly, @w*@CELLSIZE-@BORDERSIZE+2, @h*@CELLSIZE-@BORDERSIZE+2)
      
      ac.restore()
    
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
  