define ->
  # See if we're running tests or the game
  if global?
    globalscope = global
  else if window?
    globalscope = window
  else
    throw new Error 'could not find a global scope to attach $$'

  # Don't redef $ if something's there already.
  if globalscope['$$']? then return new Error '$$ already exists globally!'

  # Globally defined $ utility namespace.
  globalscope['$$'] =
    
    r : (n=1) -> n*Math.random()
    
    R : (l,h) -> Math.floor(
      l + (Math.random()*(h-l+1))
    )
    
    # Randomly choose an element from an array.
    AR : (a) -> a[ Math.floor(Math.random()*a.length) ]
    
    # Weighted object random. Selects a key from an obj based on the weight (value) of that key.
    WR : (o, sum=0) ->
      (sum += v) for k,v of o
      sum_ = 1/sum
      r = Math.random()
      (
        if !(intervalEnd?) then intervalEnd = v*sum_
        if r < intervalEnd
          return k
        else
          intervalEnd += v*sum_
          lastK = k
      ) for k, v of o
      k
    
    sum : (o, sum=0) ->
      if o instanceof Array
        sum += v for v in o
      else
        sum += v for k,v of o
      sum
    
    extend : (target, extender) ->
      target = {} unless target?
      target[k] = v for k,v of extender
      target
      
    # todo : unit test these.
    # Converted from http://ejohn.org/blog/flexible-javascript-events/

    # ex:    
    # addEvent( document.getElementById('foo'), 'click', doSomething );
    # addEvent( obj, 'mouseover', function(){ alert('hello!'); } );
    # removeEvent( object, eventType, function );
    
    addEvent : (obj, type, fn) ->
      if obj.attachEvent
        obj["e" + type + fn] = fn
        obj[type + fn] = ->
          obj["e" + type + fn](window.event)
        obj.attachEvent("on" + type, obj[type + fn])
      else
        obj.addEventListener(type, fn, false)

    removeEvent : (obj, type, fn) ->
      if obj.detachEvent
        obj.detachEvent("on" + type, obj[type + fn])
        delete obj[type + fn]
      else
        obj.removeEventListener(type, fn, false)