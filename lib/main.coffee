###
  lib/main.coffee
###

SubAtom = null

class MarkdownScrlSync
  
  activate: (state) ->
    console.log 'activate'
    SubAtom = require 'sub-atom'
    @subs = new SubAtom
    @subs.add atom.commands.add 'atom-text-editor', "markdown-scroll-sync:toggle", (e) => @toggle()

  toggle: -> console.log 'toggle'
    
  consumeStatusBar: (statusBar) ->
    @notificationEle = document.createElement 'div'
    @notificationEle.appendChild document.createTextNode 'mdSync'
    @statusBarTile = statusBar.addLeftTile item: @notificationEle, priority: 100

  startTracking: -> 
    paneView   = atom.workspaceView.getActivePaneView()
    editorView = atom.workspaceView.getActiveView()
    if not paneView or not editorView then stopTracking(); return
    
    editor = editorView.getEditor()
    buffer = editor.getBuffer()
    @subscribe buffer, "destroyed", => @stopTracking?()
    paneInfo[0] = {
      buffer, editor, editorView, paneView
      lineTop:
        editor.bufferPositionForScreenPosition( [editorView.getFirstVisibleScreenRow(), 0] ).row
      lineBot:
        editor.bufferPositionForScreenPosition( [editorView.getLastVisibleScreenRow(),  0] ).row
    }
    paneView = null
    paneViews = atom.workspaceView.getPaneViews()
    for pv in paneViews
      if pv isnt paneInfo[0].paneView
        paneView = pv
        break
    if not paneView then @stopTracking(); return
    $editorView = paneView.find '.editor:visible'
    if $editorView.length is 0 then stopTracking(); return
    editorView = $editorView.view()
    editor = editorView.getEditor()
    buffer = editor.getBuffer()
    @subscribe buffer, "destroyed", => @stopTracking?()
    paneInfo[1] = {
      buffer, editor, editorView
      lineTop:
        editor.bufferPositionForScreenPosition( [editorView.getFirstVisibleScreenRow(), 0] ).row
      lineBot:
        editor.bufferPositionForScreenPosition( [editorView.getLastVisibleScreenRow(),  0] ).row
    }
    
    @textChanged()
    @scrollPosChanged 0

    @statusBarView = new StatusBarView @
  
    for pane in [0..1] then do (pane) =>
      @subscribe paneInfo[pane].buffer, 'contents-modified',     @textChanged
      @subscribe paneInfo[pane].editor, 'scroll-top-changed', => @scrollPosChanged pane

  textChanged: ->
    diffs = dmp.diff_main paneInfo[0].buffer.getText(), paneInfo[1].buffer.getText()
    dmp.diff_cleanupSemantic diffs
    map0by1 = []
    map1by0 = []
    for diff in diffs
      [diffType, diffStr] = diff
      lineCount = diffStr.match(/\n/g)?.length ? 0
      for i in [0...lineCount]
        m0by1Len = map0by1.length
        m1by0Len = map1by0.length
        if diffType in [DIFF_EQUAL, DIFF_INSERT] then map1by0.push m0by1Len
        if diffType in [DIFF_EQUAL, DIFF_DELETE] then map0by1.push m1by0Len
    paneInfo[0].mapToOther = map0by1
    paneInfo[1].mapToOther = map1by0
    
  scrollPosChanged: (pane) -> 
      thisInfo  = paneInfo[pane]
      otherInfo = paneInfo[1-pane]
      if not thisInfo or not otherInfo or thisInfo.scrolling then return
      
      thisEditor     = thisInfo.editor
      thisEditorView = thisInfo.editorView
      thisTop = thisInfo.lineTop = \
         thisEditor.bufferPositionForScreenPosition( \
        [thisEditorView.getFirstVisibleScreenRow(), 0] ).row
      thisBot = thisInfo.lineBot = \
         thisEditor.bufferPositionForScreenPosition( \
        [thisEditorView.getLastVisibleScreenRow(),  0] ).row
      thisMid = Math.min thisInfo.mapToOther.length-1, Math.floor (thisTop + thisBot) / 2
      
      othereditorView = otherInfo.editorView

      otherTopScrnPixPos = othereditorView.pixelPositionForScreenPosition \
                          [othereditorView.getFirstVisibleScreenRow(), 0]
      otherBotScrnPixPos = othereditorView.pixelPositionForScreenPosition \
                          [othereditorView.getLastVisibleScreenRow(), 0]
      otherHalfScrnHgtPix = Math.floor (otherBotScrnPixPos.top - otherTopScrnPixPos.top) / 2
      
      otherMid = Math.min otherInfo.mapToOther.length-1, thisInfo.mapToOther[thisMid] 
      otherPos    = [otherMid, 0]
      otherPixPos = othereditorView.pixelPositionForBufferPosition otherPos
      
      otherInfo.scrolling = yes
      othereditorView.scrollTop otherPixPos.top - otherHalfScrnHgtPix
      otherInfo.scrolling = no

  stopTracking: ->
  
  deactivate: -> 
    @subs.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null  

module.exports = new MarkdownScrlSync



    
    
