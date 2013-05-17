define ->
  
  # todo: taunt with meSpeak.js
  # http://www.masswerk.at/mespeak/
  
  class Avatar
    image : null
    
    
    constructor : (params) ->
      @[k] = v for k, v of params
    
    