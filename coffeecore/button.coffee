define ->
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
      
      if @color.opacity?
        ac.globalAlpha = @color.opacity
        ac.globalCompositeOperation = 'lighter'
      
      ac.fillRect(@x, @y, @w, @h)
      ac.strokeRect(@x, @y, @w, @h)
      
      if @color.opacity?
        ac.globalAlpha = 1
        ac.globalCompositeOperation = 'source-over'
      
      
    constructor : (params) ->
      @[k] = v for k, v of params
    
    