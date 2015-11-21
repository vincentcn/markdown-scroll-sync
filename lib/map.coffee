###
  lib/map.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, map:'].concat args

module.exports =

  setMap: (getVis = yes) ->
    start = Date.now()
    timings = {}
    
    if getVis 
      @getVisTopHgtBot()
      timings['getVisTopHgtBot'] = Date.now() - start; start = Date.now()
   
    @nodes = []
    wlkr = document.createTreeWalker @previewEle, NodeFilter.SHOW_TEXT, null, yes
    while (node = wlkr.nextNode())
      text = node.textContent
      if not /\w+/.test text then continue
      [top, hgt, bot] = @getEleTopHgtBot node.parentNode, no
      @nodes.push [top, bot, null, null, text, null]
      
    timings['tree walk'] = Date.now() - start; start = Date.now()
    
    nodePtr = 0
    for bufRow in [0..@editor.getLastBufferRow()]
      line = @editor.lineTextForBufferRow bufRow
      if not (matches = line.match /[a-z0-9-\s]+/ig) then continue
      maxLen = 0
      target = null
      for match in matches when /\w+/.test match
        match = match.replace /^\s+|\s+$/g, ''
        if match.length > maxLen
          maxLen = match.length
          target = match
      if target
        nodeMatch = null
        for node, idx in @nodes[nodePtr...]
          if node[4].includes target
            if nodeMatch then nodeMatch = 'dup'; break
            nodeMatch = node
            idxMatch = idx
        if not nodeMatch or nodeMatch is 'dup' then continue
        {start:{row:topRow},end:{row:botRow}} =
          @editor.screenRangeForBufferRange [[bufRow, 0],[bufRow, 9e9]]
        nodeMatch[2] = topRow
        nodeMatch[3] = botRow
        nodeMatch[5] = target  # DEBUG
        nodePtr = idxMatch
        
    timings['node match'] = Date.now() - start; start = Date.now()
    
    @map = [[0,0,0,0]]
    @lastTopPix = @lastBotPix = @lastTopRow = @lastBotRow = 0
    firstNode = yes
    
    addNodeToMap = (node) =>
      [topPix, botPix, topRow, botRow] = node
      if topPix <  @lastBotPix or
         topRow <= @lastBotRow
        @lastTopPix = Math.min topPix, @lastTopPix
        @lastBotPix = Math.max botPix, @lastBotPix
        @lastTopRow = Math.min topRow, @lastTopRow
        @lastBotRow = Math.max botRow, @lastBotRow
        @map[@map.length - 1] = 
          [@lastTopPix, @lastBotPix, @lastTopRow, @lastBotRow]
      else
        if firstNode
          @map[0][1] = topPix
          @map[0][3] = Math.max 0, topRow - 1
        @map.push [@lastTopPix = topPix,
                   @lastBotPix = botPix, 
                   @lastTopRow = topRow, 
                   @lastBotRow = botRow]
      firstNode = no
      
    for node in @nodes when node[2] isnt null
      addNodeToMap node
    
    botRow = @editor.getLastScreenRow()
    topRow = Math.min  botRow, @lastBotRow + 1
    addNodeToMap [@lastBotPix, @previewEle.scrollHeight, topRow, botRow]
    
    @nodes = null
      
    # timings['map merge'] = Date.now() - start; start = Date.now()
    # str = ''
    # for k, v of timings then str +=  '  ' + k + ': ' + v
    # log 'timings', str
