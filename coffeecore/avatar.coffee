define ->
  
  # todo: taunt with meSpeak.js
  # http://www.masswerk.at/mespeak/
  
  class Avatar
    image : null
    
    x : 0
    y : 0
    
    move : ->
    
    taunt : ->
    
    constructor : (params) ->
      @[k] = v for k, v of params
    
    