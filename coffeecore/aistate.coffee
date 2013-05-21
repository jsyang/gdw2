define ->
  
  class AIState
  
    color : 2 # computer plays black
  
    constructor : (params) ->
      @[k] = v for k, v of params
      if !(@game?) then throw new Error 'no game reference was given to create the state object!'
    
    countAvailableMovesFromCell : (refcell,x,y) ->
      # [x, y] is relative to the board origin.
      movesAvailable = 0
      
      if !x? or !y?
        x = refcell.x
        y = refcell.y
      else if !refcell?
        refcell = @board[y*@boardW+x]
      
      
      # Moves available in the same row
      for i in [0...@boardW]
        cell = @board[i+@boardW*y]
        if cell.control is 0 and cell.value >= 0 and refcell != cell and cell.tile != @game.user.lastTile
          movesAvailable++
      
      # Moves available in the same column
      for j in [0...@boardH]
        cell = @board[x+@boardW*j]
        if cell.control is 0 and cell.value >= 0 and refcell != cell and cell.tile != @game.user.lastTile
          movesAvailable++
      
      movesAvailable
    
    setBoard : ->
      @boardW = @game.user.layout.bx - @game.user.layout.x
      @boardH = @game.user.layout.by - @game.user.layout.y
    
      # init the board with -1s to show illegal moves
      @board = ({
        control : 0     # who controls this cell
        value   : -1    # "desirability of playing here" metric
        tile    : null  # reference to the tile which this cell belongs to
      } for i in [0...@boardW*@boardH])
      
      
      # Set the initial values of the tiles' cells
      for t in @game.tiles
        for i in [0...t.h]
          for j in [0...t.w]
            # absolute position. refs top left corner of the board.
            cx = t.lx+j
            cy = t.ly+i
            cell = @board[cy*@boardW+cx]
            if !cell?
              console.log(cx, cy)
            cell.value = 0
            cell.x = cx
            cell.y = cy
            cell.tile = t
      
      # Add to the non-negative cells (legal moves)
      @updateBoard()
      
    
    # Change the ranking 
    updateBoard : ->
      # Add to the non-negative cells (legal moves)
      for t in @game.tiles
        marblesOnTile = 
          'red'   : 0
          'black' : 0
          
        for i in [0...t.h]
          for j in [0...t.w]
            cx = t.lx+j
            cy = t.ly+i
            cell = @board[cy*@boardW+cx]
            if cell.control is 0 and cx is @game.user.lastMove.x and cy is @game.user.lastMove.y
              cell.control = ((@game.user.color+1) % 2) + 1
              cell.value = -1
            else if cell.value > 0
              if cell.control is 0
                # todo : tweak this as needed.
                cell.value = @countAvailableMovesFromCell(cell) + t.score
              else
                if cell.control is 1
                  marblesOnTile.red++
                else if cell.control is 2
                  marblesOnTile.black++
        
        if Math.max(marblesOnTile.red, marblesOnTile.black) > t.score>>1
          # Not worth fighting for the tile anymore since majority has been achieved.
          # Mark all cells in tile as worthless.
          for i in [0...t.h]
            for j in [0...t.w]
              cx = t.lx+j
              cy = t.ly+i
              cell = @board[cy*@boardW+cx]
              cell.control = -1
              cell.value = -1
      return
    
    findBestMove : ->
      # just use the best cells in terms of values for now
      lastMove =
        x     : @game.user.lastMove.x# - @game.user.layout.x
        y     : @game.user.lastMove.y# - @game.user.layout.y
        tile  : @game.user.lastTile
      
      bestMove =
        x : -1
        y : -1
        value : -1
      
      # Moves available in the same row
      for i in [0...@boardW]
        cell = @board[i+@boardW*lastMove.y]
        if cell.control is 0 and cell.value >= 0 and i != lastMove.x and cell.tile != lastMove.tile
          if cell.value > bestMove.value
            bestMove =
              x     : i
              y     : lastMove.y
              value : cell.value
              tile  : cell.tile
      
      # Moves available in the same column
      for j in [0...@boardH]
        cell = @board[lastMove.x+@boardW*j]
        if cell.control is 0 and cell.value >= 0 and j != lastMove.y and cell.tile != lastMove.tile
          if cell.value > bestMove.value
            bestMove =
              x     : lastMove.x
              y     : j
              value : cell.value
              tile  : cell.tile
      
      bestMove # relative to layout (board) origin
    
    # Update only the potential moves from the last move played
    updateWithLastMove : ->
      # todo?
    