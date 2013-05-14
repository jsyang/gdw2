define [
  'core/tile'
  'core/button'
], (MoveTile, Button) ->
    
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
      
    
    findTileAt : (x,y) ->
      for t in @tiles
        if t.containsPoint(x, y) # in pixels
          return t
      null
      
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
    
    createRandomLayout : ->
      tilePool = @tiles.slice()
      @tiles = []
      
      # start from here, iterate downwards
      [x, y]  = [1, 1]
      minX    = x
      maxX    = 16
      
      @user.layout.x = x
      @user.layout.y = y
      
      # side-effects may include infinite loops and drowsiness
      tryLayingTile = (t) =>
        invalid = true
        i = 0
        while invalid
          if i is 0
            t.transposeOrientation()
          else
            t.x+=32
            if t.x>>5 > maxX
              t.x = minX<<5
              t.y+=32
          i++
          i %= 2
          invalid = !@verifyLayoutValid()
        
        return
      
      while tilePool.length > 0
        i = $$.R(0,tilePool.length-1)
        tileToPlace = tilePool[i]
        tilePool.splice(i,1)
        @tiles.push(tileToPlace)
        
        # try placing one at "cursor" location
        tileToPlace.x = x<<5
        tileToPlace.y = y<<5
        tryLayingTile(tileToPlace)
        x = tileToPlace.x>>5
        y = tileToPlace.y>>5
        
      # random layout generation was successful. begin the game.
      @triggers.startgame.call(@)
      
      return

    
    user :
      moves : 0
    
      COLORS : [ null, 'red', 'black' ]
      
      color : 1
    
      lastClick   : 0
      lastButton  : null
      lastMove :
        x : -1
        y : -1
      
      lastTile    : null     
      tile        : null  # currently clicked tile

      layout    :
        # used to calculate whether or not a player has any moves left
        array : null
        # units for these coords are in tiles, not pixels
        x   : 0   
        y   : 0
        bx  : 0   # max X
        by  : 0   # max Y
      mouseOffset :
        x : 0
        y : 0

    checkIfPlayerHasMovesLeft : ->
      # check horizontal
      y = @user.lastMove.y + @user.layout.y
      (
        t = @findTileAt(x<<5,y<<5) 
        if t? and t != @user.lastTile and t.getOuterCell(x-@user.layout.x,y-@user.layout.y) is 0
          return true
      ) for x in [@user.layout.x..@user.layout.bx]
      
      # check vertical
      x = @user.lastMove.x + @user.layout.x
      (
        t = @findTileAt(x<<5,y<<5) 
        if t? and t != @user.lastTile and t.getOuterCell(x-@user.layout.x,y-@user.layout.y) is 0
          return true
      ) for y in [@user.layout.y..@user.layout.by]
      
      false
      
    mode :
      current : 'select'
      
      gameover : (dt) ->

      play : (dt) ->
        if (atom.input.pressed('touchfinger') or atom.input.pressed('mouseleft'))
          if @findUIThing('tiles')
            mouse = @translateMouseToLayout()
            if  (@user.tile is @user.lastTile) or
                (@user.tile.getOuterCell(mouse.x, mouse.y) > 0) or
                (@user.moves > 0 and (mouse.x != @user.lastMove.x and mouse.y != @user.lastMove.y))
              
              # already played here. illegal move
              @triggers.addhighlightbutton.apply(@)
            else
              @user.tile.setOuterCell(mouse.x, mouse.y, @user.color)
              @user.lastTile = @user.tile
              @user.color++
              if @user.color > 2 then @user.color = 1
              @triggers.removehighlightbutton.apply(@)
              @user.lastMove = mouse
                
              if !@checkIfPlayerHasMovesLeft()
                alert('No moves left for '+@user.COLORS[@user.color]+'!')
                @triggers.calculatescores.call(@)
              
              @user.moves++
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
        
        if (atom.input.pressed('touchfinger') or atom.input.pressed('mouseleft'))
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
      addhighlightbutton : ->
        @buttons.highlightLastMove = new Button({
          x : (@user.layout.x + @user.lastMove.x)<<5
          y : (@user.layout.y + @user.lastMove.y)<<5
          w : 32
          h : 32
          clicked : null
          color :
            opacity : 0.75
            pressed : '#5a9'
            up      : '#5a9'
        })
    
      removehighlightbutton : ->
        delete @buttons.highlightLastMove if @buttons.highlightLastMove?
    
      removerandomlayoutbutton : ->
        delete @buttons.randomLayout if @buttons.randomLayout?
    
      removestartbutton : ->
        delete @buttons.start if @buttons.start?
          
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
        @triggers.removestartbutton.call(@)
        @triggers.removerandomlayoutbutton.call(@)
        @mode.current = 'play'
        
      generaterandomlayout : -> @createRandomLayout()
      
      calculatescores : ->
        scores =
          red   : 0
          black : 0
          
        for t in @tiles
          scoreWithinTile = 
            red   : 0
            black : 0
            
          for i in t.cells
            switch i
              when 1
                scoreWithinTile.red++
              when 2
                scoreWithinTile.black++
                
          if scoreWithinTile.red > scoreWithinTile.black
            scores.red += t.w*t.h
          else if scoreWithinTile.red < scoreWithinTile.black
            scores.black += t.w*t.h
        
        alert("Final scores:\nRED\t\t#{scores.red}\nBLACK\t#{scores.black}")
        
        @mode.current = 'gameover'
    
    tiles : []
    
    buttons :
    
      randomLayout : new Button({
        x : atom.width - 100
        y : 120
        w : 80
        h : 80
        clicked : 'generaterandomlayout'
        color :
          pressed : '#d3f'
          up      : '#d3f'
      })
      
      start : new Button({
        x : atom.width - 100
        y : 20
        w : 80
        h : 80
        clicked : null
        color :
          pressed : '#0a0'
          up      : '#3e8'
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
  
      # make sure we don't waste them precious cycles.
      window.onblur = => @stop
      window.onfocus = => @run
      
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])
    
    draw : ->
      atom.context.clear()
      t.draw() for t in @tiles
      v.draw() for k,v of @buttons