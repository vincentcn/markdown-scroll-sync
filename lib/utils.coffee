###
  lib/utils.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, utils:'].concat args

module.exports =

  getVisTopHgtBot: ->
    {top: @edtTopBnd, bottom: edtBotBnd} = @editorView.getBoundingClientRect()
	 # Fix for issue #64, March 4, 2017
	 # Implemented by Michael Fierro (biffster@gmail.com)
	 # Super-simple fix, just remove ".shadowRoot" from the line below.
    # lineEles = @editorView.shadowRoot.querySelectorAll '.lines .line[data-screen-row]'
    lineEles = @editorView.querySelectorAll '.lines .line[data-screen-row]'
    lines = []
    for lineEle in lineEles
      {top: lineTopBnd} = lineEle.getBoundingClientRect()
      lines.push [+lineEle.getAttribute('data-screen-row'), lineTopBnd]
    if lines.length is 0
      log 'no visible lines in editor'
      @scrnTopOfs = @scrnBotOfs = @pvwTopB = @previewTopOfs = @previewBotOfs = 0
      return
    lines.sort()
    for refLine in lines
      if refLine[1] >= @edtTopBnd then break
    [refRow, refTopBnd] = refLine
    @scrnTopOfs = (refRow * @chrHgt) - (refTopBnd - @edtTopBnd)
    @scrnHeight = edtBotBnd - @edtTopBnd
    @scrnBotOfs = @scrnTopOfs + @scrnHeight
    botScrnScrollRow = @editor.clipScreenPosition([9e9, 9e9]).row
    @scrnScrollHgt = (botScrnScrollRow + 1) * @chrHgt
    
    {top: @pvwTopBnd, bottom: pvwBotBnd} = @previewEle.getBoundingClientRect()
    @previewTopOfs = @previewEle.scrollTop
    @previewBotOfs = @previewTopOfs + (pvwBotBnd - @pvwTopBnd)

  getEleTopHgtBot: (ele, scrn = yes) ->
    {top:eleTopBnd, bottom: eleBotBnd} = ele.getBoundingClientRect()
    top = if scrn then @scrnTopOfs    + (eleTopBnd - @edtTopBnd) \
                  else @previewTopOfs + (eleTopBnd - @pvwTopBnd)
    hgt = eleBotBnd - eleTopBnd
    bot = top + hgt
    [top, hgt, bot]
  
