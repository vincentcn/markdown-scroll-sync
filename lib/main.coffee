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
        # console.log 'markdown-scroll-sync: markdown-preview package not found'
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
      if topRow isnt lastTopRow
        lastTopRow = topRow
        # console.log 'topRow', topRow
        try
          bufPos = editor.bufferPositionForScreenPosition [topRow+1, 0]
        catch e
          console.log 'markdown-scroll-sync: error in bufferPositionForScreenPosition', 
            {editor, topRow, e}
          return
        @scroll preview, editor.getTextInBufferRange [[0,0], bufPos]
    , 300
      
  scroll: (preview, text) ->
    @roaster text, {}, (err, html) =>
      numEles = html.match(/<h1|<h2|<h3|<div|<p|<img|<ul|<li/gi)?.length ? 0
      $ele = $(preview).find('h1,h2,h3,div,p,img,ul,li').eq numEles-1
      # console.log 'getSelector', {err, html, numEles, $ele}
      $ele[0]?.scrollIntoView()

  stopTracking: ->
    if @scrollInterval 
      clearInterval @scrollInterval
      @scrollInterval = null
      
  deactivate: -> 
    @stopTracking()
    @subs.dispose()

module.exports = new MarkdownScrlSync



    
    
