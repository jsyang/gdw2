define ->
  class MoveTile
    BORDERSIZE        : 4
    BORDERSIZE_       : 0.25
    CELLSIZE          : 32 # or 1<<5
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
      return ( @x <= x < @x+@CELLSIZE*@w ) and ( @y <= y < @y+@CELLSIZE*@h )
    
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
  