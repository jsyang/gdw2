define [
  'core/tile'
  'core/button'
  'core/instructions'
  'core/aistate'
  'core/aiplayer'
], (MoveTile, Button, Instructions, AIState, AIPlayer) ->
    
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
      for i in [@tiles.length-1..0]
        t = @tiles[i]
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
          for i in [@tiles.length-1..0]
            t = @tiles[i]
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
      maxX        = 10
      
      [x, y]      = [((atom.width>>5)-maxX)>>1, 1]
      minX        = x
      maxX       += x
      
      # chance the tryLayingTile operation will result in a hole!
      holeChance  = 0.6
      
      @user.layout.x = x
      @user.layout.y = y
      
      # side-effects may include infinite loops and drowsiness
      tryLayingTile = (t) =>
        invalid = true
        i = 0
        while invalid
          if i is 0 and $$.r() > holeChance
            t.transposeOrientation()
          else
            t.x+=32
            if t.x>>5 > maxX
              t.x = minX<<5
              t.y+=32
          
          i++
          i %= 2
          invalid = !@verifyLayoutValid()
          
          # ragequit due to ineptness
          if t.y > 40<<5 then return false
        
        return true
      
      while tilePool.length > 0
        i = $$.R(0,tilePool.length-1)
        tileToPlace = tilePool[i]
        tilePool.splice(i,1)
        @tiles.push(tileToPlace)
        
        # try placing one at "cursor" location
        tileToPlace.x = x<<5
        tileToPlace.y = y<<5
        if !tryLayingTile(tileToPlace)
          @tiles = @tiles.concat(tilePool)
          return false
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
      
      lastMouse : # for tile rotation
        x : 0
        y : 0
      
      lastTile    : null     
      tile        : null  # currently clicked tile

      layout    :
        # units for these coords are in tiles, not pixels
        x   : 0   
        y   : 0
        bx  : 0   # max X (bounds X)
        by  : 0   # max Y (bounds Y)
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
              @triggers.showbadmove.call(@)
              
            else
              @triggers.movemade.call(@, mouse)
                
              #@user.tile.setOuterCell(mouse.x, mouse.y, @user.color)
              #@user.lastTile = @user.tile
              #@user.color++
              #if @user.color > 2 then @user.color = 1
              #@triggers.removehighlightbutton.apply(@)
              #@user.lastMove = mouse
              #
              #@user.moves++
              #atom.playSound('crack')
              #
              #if !@checkIfPlayerHasMovesLeft()
              #  @triggers.showgameover.call(@)
              #  alert('No moves left for '+@user.COLORS[@user.color]+'!')
              #  @triggers.calculatescores.call(@)
              #else
              #  @triggers.showwhosturn.call(@)
          
          else if @findUIThing('buttons')
            atom.playSound('drop')
            @triggers[@user.lastButton.clicked].apply(@) if @user.lastButton.clicked?
              
          
      
      select : (dt) ->
        
        @user.lastClick += dt
        
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
        
          if @findUIThing('tiles')
            # double click to change orientation
            if @user.lastTile is @user.tile and @user.lastClick < 0.3
              
              @user.tile.transposeOrientation()
              atom.playSound('drop')
              @user.lastTile = null
            else
              # selected a tile to move
              @user.lastClick = 0
              @mode.current = 'move'
              @user.lastTile = @user.tile
              
              frontIndex  = @tiles.indexOf(@user.lastTile)
              if frontIndex != @tiles.length-1
                front       = @tiles[frontIndex]
                @tiles.splice(frontIndex, 1)
                @tiles.push(front)
              
              atom.playSound('pick')
            
        
        
        if (atom.input.pressed('touchfinger') or atom.input.pressed('mouseleft'))
          if @findUIThing('buttons')
            atom.playSound('drop')
            @triggers[@user.lastButton.clicked].apply(@) if @user.lastButton.clicked?
            
      move : (dt) ->
        
        @user.lastClick += dt
        
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
          
          diff =
            x : atom.input.mouse.x - @user.lastMouse.x
            y : atom.input.mouse.y - @user.lastMouse.y
            
          # wiggling the pieces as you drag them
          magnitude = Math.abs(diff.x) + Math.abs(diff.y)
          sign      = if diff.x > 0 then 1 else -1
          
          newRotation = Math.log(magnitude)*0.16*sign unless magnitude is 0
          @user.tile.rotation = newRotation unless Math.abs(newRotation) < 0.09 or !(newRotation?)
              
          @user.lastMouse =
            x : atom.input.mouse.x
            y : atom.input.mouse.y
      
    
    triggers : ######################################################################################
    
      movemade : (coord) ->
          @user.tile.setOuterCell(coord.x, coord.y, @user.color)
          @user.lastTile = @user.tile
          @user.color++
          if @user.color > 2 then @user.color = 1
          @triggers.removehighlightbutton.apply(@)
          @user.lastMove = coord
          
          @user.moves++
          atom.playSound('crack')
          
          if !@checkIfPlayerHasMovesLeft()
            @triggers.showgameover.call(@)
            alert('No moves left for '+@user.COLORS[@user.color]+'!')
            @triggers.calculatescores.call(@)
          else
            @triggers.showwhosturn.call(@)
            
            # Make sure the game is not over before we attempt an AI move
            if @ai?
              @aistate.updateBoard()
              if @user.color is @ai.color
                # make a move only after the turn's done
                setTimeout((=> @ai.makeMove()), 100)
    
      showgameover : ->
        @instructions.set({ name : 'NEUTRAL_GAMEOVER' })
        
      showbadmove : ->
        @instructions.set({ name : 'BAD_MOVEINVALID' })
      
      showwhosturn : ->
        @instructions.set({ name : 'NEUTRAL_'+@user.COLORS[@user.color].toUpperCase()+'STURN' })
    
      removehelpnavigationbuttons : ->
        delete @buttons.fastForward if @buttons.fastForward?
        delete @buttons.rewind if @buttons.rewind?
    
      disablehelprewind : ->
        b = @buttons.rewind
        if b?
          b.color.opacity = 0.5
          b.clicked = null
      
      enablehelprewind : ->
        b = @buttons.rewind
        if b?
          delete b.color.opacity
          b.clicked = 'helprewind'
          
      disablehelpfastforward : ->
        b = @buttons.fastforward
        if b?
          b.color.opacity = 0.5
          b.clicked = null
      
      enablehelpfastforward : ->
        b = @buttons.fastforward
        if b?
          delete b.color.opacity
          b.clicked = 'helpfastforward'
    
      helpfastforward : ->
        @instructions.nextInSequence()
      
      helprewind : ->
        @instructions.prevInSequence()
      
      addhelpnavigationbuttons : ->
        @buttons.fastForward = new Button({
          x : atom.width - 171
          y : atom.height - 60
          w : 61
          h : 50
          shape : 'image'
          image : 'button_fastforward'
          clicked : 'helpfastforward'
          color :
            pressed : '#F7C839'
            up      : '#F7C839'
        })
        
        @buttons.rewind = new Button({
          x : atom.width - 242
          y : atom.height - 60
          w : 61
          h : 50
          shape : 'image'
          image : 'button_rewind'
          clicked : 'helprewind'
          color :
            pressed : '#F7C839'
            up      : '#F7C839'
        })
        
        @triggers.disablehelprewind.call(@)
      
      addhighlightbutton : ->
        atom.playSound('invalid')
        
        @buttons.highlightLastMove = new Button({
          x : (@user.layout.x + @user.lastMove.x)<<5
          y : (@user.layout.y + @user.lastMove.y)<<5
          w : 32
          h : 32
          clicked : null
          color :
            opacity : 0.5
            pressed : '#F7C839'
            up      : '#F7C839'
        })
    
      removehighlightbutton : ->
        delete @buttons.highlightLastMove if @buttons.highlightLastMove?
    
      removerandomlayoutbutton : ->
        delete @buttons.randomLayout if @buttons.randomLayout?
        
      removehelpbutton : ->
        delete @buttons.help if @buttons.help?
    
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
            opacity : 0.75
          b.clicked = 'invalidstart'
        
      startgame : ->
        (
          t.lockOrientation()
          t.lx = (t.x>>5) - @user.layout.x
          t.ly = (t.y>>5) - @user.layout.y
        ) for t in @tiles
        @triggers.removestartbutton.call(@)
        @triggers.removerandomlayoutbutton.call(@)
        #@triggers.removehelpbutton.call(@)
        # Use it for instructions instead
        @buttons.help.clicked = 'showgameruleshelp'
        
        @mode.current = 'play'
        @user.lastTile = null
        atom.playSound('valid')
        @triggers.showwhosturn.call(@)
        
        @aistate  = new AIState({ game : @ })
        @ai       = new AIPlayer({ game : @ })
        
        # Set the AI's perception of the cell values
        @aistate.setBoard()
        
      generaterandomlayout : -> @createRandomLayout()
      
      invalidstart : -> atom.playSound('invalid')
      
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
        
        if scores.black > scores.red
          endquip = 'Black wins.'
        else if scores.black is scores.red
          endquip = 'Draw.'
        else
          endquip = 'Red wins.'
        
        if @ai
          if @ai.color is 2
            if scores.black > scores.red
              endquip +='\nYou lose, human!'
        
        @instructions.NEUTRAL_GAMEOVER.text = "GAME OVER!\nFinal scores:\nRED -> #{scores.red}\nBLACK -> #{scores.black}\n\n#{endquip}"
        @instructions.set({ name : 'NEUTRAL_GAMEOVER' })
        
        @mode.current = 'gameover'
      
      showgameruleshelp : ->
        @instructions.set({ name : 'HELP' })
        @triggers.addhelpnavigationbuttons.call(@)

      
      showtileplacementhelp : ->
        @instructions.set({ name : 'NEUTRAL_BOARDSETUP' })
    
    tiles : []
    
    buttons :
    
      randomLayout : new Button({
        x : atom.width - 248
        y : atom.height - 60
        w : 138
        h : 50
        shape : 'image'
        image : 'button_random'
        clicked : 'generaterandomlayout'
        color :
          pressed : '#d3f'
          up      : '#d3f'
      })
      
      start : new Button({
        x : atom.width - 347
        y : atom.height - 60
        w : 90
        h : 50
        shape : 'image'
        image : 'button_play'
        clicked : null
        color :
          pressed : '#0a0'
          up      : '#3e8'
      })
    
      help : new Button({
        x : atom.width - 100
        y : atom.height - 60
        w : 89
        h : 50
        shape : 'image'
        image : 'button_help'
        clicked : 'showtileplacementhelp'
        color :
          pressed : '#0a0'
          up      : '#3e8'
      })
    
    # aistate : null
    # instructions : null
    
    constructor : ->
    
      makeTile = (size) =>
        @tiles.push(
          new MoveTile({
            size
            x     : $$.R(1,200)
            y     : $$.R(1,200)
          })
        )
        
      tileList =  # The full list for kulami.
        '3x2' : 4
        '2x2' : 5
        '3x1' : 4
        '2x1' : 4
      
      ( makeTile(k) for i in [0...v] ) for k,v of tileList
    
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
  
      # make sure we don't waste them precious cycles.
      window.onblur = => @stop
      window.onfocus = => @run
      
      # initially, you can't play since the tiles are jumbled
      @triggers.disablestartbutton.call(@)
      
      @instructions = new Instructions({ game : @ })
      
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])
    
    draw : ->
      atom.context.clear()
      t.draw() for t in @tiles
      v.draw() for k,v of @buttons
      
      @instructions.draw()
      