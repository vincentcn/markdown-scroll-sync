###
  lib/scroll.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, scroll:'].concat args
  args[0]

module.exports =
  
  chkScroll: (eventType, auto) -> 
    if @scrollTimeout
      clearTimeout @scrollTimeout
      @scrollTimeout = null
      
    if not @editor.alive then @stopTracking(); return

    if eventType isnt 'changed'
      @getVisTopHgtBot()
      if @scrnTopOfs    isnt @lastScrnTopOfs or
         @scrnBotOfs    isnt @lastScrnBotOfs or
         @previewTopOfs isnt @lastPvwTopOfs  or
         @previewBotOfs isnt @lastPvwBotOfs
        @lastScrnTopOfs = @scrnTopOfs
        @lastScrnBotOfs = @scrnBotOfs
        @lastPvwTopOfs  = @previewTopOfs
        @lastPvwBotOfs  = @previewBotOfs
    
      # {width:scrnW, height:scrnH} = @editorView.getBoundingClientRect()
      # {width:pvwW, height:pvwH}   = @previewEle.getBoundingClientRect()
      # if scrnW isnt @lastScrnW or
      #    scrnH isnt @lastScrnH or
      #    pvwW  isnt @lastPvwW  or
      #    pvwH  isnt @lastPvwH
      #   @lastScrnW = scrnW    
      #   @lastScrnH = scrnH
      #   @lastPvwW  = pvwW 
      #   @lastPvwH  = pvwH 
      
        @setMap no
    
    switch eventType
      when 'init'
        cursorOfs  = @editor.getCursorScreenPosition().row * @chrHgt
        if @scrnTopOfs <= cursorOfs <= @scrnBotOfs 
             @setScroll cursorOfs
        else @setScroll @scrnTopOfs
          
      when 'changed', 'cursorMoved' 
        @setScroll @editor.getCursorScreenPosition().row * @chrHgt
        @ignoreScrnScrollUntil = Date.now() + 500
      
      when 'newtop'
        if @ignoreScrnScrollUntil and
           Date.now() < @ignoreScrnScrollUntil then break
        @ignoreScrnScrollUntil = null
        scrollFrac = @scrnTopOfs / (@scrnScrollHgt - @scrnHeight)
        @setScroll   @scrnTopOfs + (@scrnHeight * scrollFrac)
        if not auto
          @scrollTimeout = setTimeout (=> @chkScroll 'newtop', yes), 300
  
  setScroll: (scrnPosPix) ->
    scrnPosPix = Math.max 0, scrnPosPix
    lastMapping = null
    for mapping, idx in @map
      [topPix, botPix, topRow, botRow] = mapping
      if (topRow * @chrHgt) <= scrnPosPix < ((botRow+1) * @chrHgt) or 
          idx is @map.length - 1
        row1 = topRow
        row2 = botRow + 1
        pix1 = topPix
        pix2 = botPix
        break      
      else
        lastMapping ?= mapping
        lastBotPix = lastMapping[1]
        lastBotRow = lastMapping[3] + 1
        if (lastBotRow * @chrHgt) <= scrnPosPix < (topRow * @chrHgt)
          row1 = lastBotRow
          row2 = topRow
          pix1 = lastBotPix
          pix2 = topPix
          break
      lastMapping = mapping
      
    spanFrac  = (scrnPosPix - (row1 * @chrHgt)) / ((row2 - row1) * @chrHgt)
    visOfs    =  scrnPosPix - @scrnTopOfs
    pvwPosPix = pix1 + ((pix2 - pix1) * spanFrac)
    @previewEle.scrollTop = pvwPosPix - visOfs
    
