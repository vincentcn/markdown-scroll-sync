###
  lib/main.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, main:'].concat args

SubAtom  = require 'sub-atom'

class MarkdownScrlSync
  
  activate: (state) ->
    pathUtil     = require 'path'
    {TextEditor} = require 'atom'
    @subs        = new SubAtom

    if not (prvwPkg = atom.packages.getLoadedPackage 'markdown-preview') and
       not (prvwPkg = atom.packages.getLoadedPackage 'markdown-preview-plus')
      log 'markdown preview package not found'
      return

    viewPath = pathUtil.join prvwPkg.path, 'lib/markdown-preview-view'
    MarkdownPreviewView  = require viewPath
    
    @subs.add atom.workspace.observeActivePaneItem (editor) =>
      isMarkdown = (editor)->
        for name in ["GitHub Markdown", "CoffeeScript (Literate)"]
          return true if editor.getGrammar()?.name is name
        if(path = editor.getPath())
          [fpath, ..., fext] = path.split('.')
          return true if fext.toLowerCase() is 'md'
        false
      if editor instanceof TextEditor and
         editor.alive                 and
         isMarkdown(editor)
        @stopTracking()
        for previewView in atom.workspace.getPaneItems() 
          if previewView instanceof MarkdownPreviewView and 
             previewView.editor is editor
            @startTracking editor, previewView
            break
        null

  startTracking: (@editor, previewView) ->
    @editorView    = atom.views.getView @editor
    @previewEle    = previewView.element
    
    @chrHgt = @editor.getLineHeightInPixels()
    @lastScrnRow = null
    @lastChrOfs  = 0
    
    @setMap()
    @chkScroll 'init'
    
    @subs2 = new SubAtom
    @subs2.add @editor    .onDidStopChanging         => @setMap(); @chkScroll 'changed'
    @subs2.add @editor    .onDidChangeCursorPosition => @chkScroll 'cursorMoved'
    @subs2.add @editorView.onDidChangeScrollTop      => @chkScroll 'newtop'
    @subs2.add @editor    .onDidDestroy              => @stopTracking()
    
  stopTracking: ->
    @subs2.dispose() if @subs2
    @subs2 = null
      
  deactivate: -> 
    @stopTracking()
    @subs.dispose()

mix = (mixinName) ->
  mixin = require './' + mixinName
  for key in Object.keys mixin
    MarkdownScrlSync.prototype[key] = mixin[key]

mix 'map'
mix 'scroll'
mix 'utils'

module.exports = new MarkdownScrlSync
