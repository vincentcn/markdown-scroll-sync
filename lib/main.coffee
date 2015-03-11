###
  lib/main.coffee
###

$ = null

class MarkdownScrlSync
  
  activate: (state) ->
    process.nextTick =>
      # console.log 'markdown-scroll-sync: activate '
      pathUtil     = require 'path'
      @roaster     = require 'roaster'
      
      {TextEditor} = require 'atom'
      {$}          = require 'space-pen'
      SubAtom      = require 'sub-atom'
      @subs        = new SubAtom

      
      if not (prvwPkg = atom.packages.getLoadedPackage 'markdown-preview')
        console.log 'markdown-scroll-sync: markdown-preview package not found'
        return
      viewPath = pathUtil.join prvwPkg.path, 'lib/markdown-preview-view'
      MarkdownPreviewView  = require viewPath
      
      @subs.add atom.workspace.observeActivePaneItem (editor) =>
        if editor instanceof TextEditor and 
           editor.getGrammar().name is 'GitHub Markdown'
          @stopTracking()
          for preview in atom.workspace.getPaneItems() 
            if preview.editor is editor
              @startTracking editor, preview
              break
          null
  
  startTracking: (editor, preview) ->
    editorView = atom.views.getView editor
    if not (shadow = editorView.shadowRoot) then return
    $lines = $ shadow.querySelector '.lines'
    
    lastTopRow = null
    @scrollInterval = setInterval =>
      topRow = Math.min()
      $lines.find('.line').each (idx, ele) =>
        row = $(ele).attr 'data-screen-row'
        topRow = Math.min topRow, row
      topRow += 1
      if topRow isnt lastTopRow
        lastTopRow = topRow
        # console.log 'topRow', topRow
        try
          bufPos = editor.bufferPositionForScreenPosition [topRow+1, 0]
        catch e
          console.log 'markdown-scroll-sync: error in bufferPositionForScreenPosition', 
            {editor, topRow, e}
          return
        mdBeforeTopLine = editor.getTextInBufferRange [[0,0], bufPos]
        @scroll preview, mdBeforeTopLine
        
        # fs.writeFileSync 'C:\\atom\\markdown-scroll-sync\\mdBeforeTopLine.md', mdBeforeTopLine
    , 300

  walkDOM: (node) ->
    node = node.firstChild
    while node
      # console.log 'nodeName', node.nodeName, node.nodeType
      # if node.nodeType is 3 then console.log node.data
      if node.nodeType in [1,8] 
        @resultNode = node
        --@numEles
      if @numEles <= 0 then return
      if node.nodeName.toLowerCase().indexOf('atom-') < 0 then @walkDOM node
      # else debugger
      if @numEles <= 0 then return
      node = node.nextSibling
      
  scroll: (preview, text) ->
    @roaster text, {}, (err, html) =>
      # fs.writeFileSync 'C:\\atom\\markdown-scroll-sync\\htmlBeforeTopLine.html', html
      
      @numEles = 0
      regex = new RegExp '<([^\\/][a-z]*).*?>', 'g'
      while (match = regex.exec html)
        if match[1].toLowerCase() isnt 'code'
          @numEles++
      
      # console.log 'before walkDOM', @numEles
      @resultNode = preview[0]
      @walkDOM @resultNode
      @resultNode.scrollIntoView()
      # console.log 'walkDOM done', @resultNode

  stopTracking: ->
    if @scrollInterval 
      clearInterval @scrollInterval
      @scrollInterval = null
      
  deactivate: -> 
    @stopTracking()
    @subs.dispose()

module.exports = new MarkdownScrlSync



    
    
