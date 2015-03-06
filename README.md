# markdown-scroll-sync Atom editor package

Auto-scroll markdown-preview tab to match markdown source.  See the project at [github](https://github.com/mark-hahn/markdown-scroll-sync).

---

![Image inserted by Atom editor package auto-host-markdown-image](http://i.imgur.com/X3fVXdL.gif)

---

### Usage:

There is no atom command or keybinding. There are no config settings.

The package starts on load and watches for when it should sync.  It will automatically sync when there are two panes where one active tab is a markdown file and another active tab is the markdown preview for that file.  At that point it will scroll the preview to match the markdown file's scroll position.  

When the markdown file is scrolled the preview is automatically scrolled to match.  If the preview is scrolled then syncing is temporarily turned off until the main file is focused again.  The markdown file is never automatically scrolled to match the preview.

### License

Copyright Mark Hahn by MIT license.

### Advertisement.  

See other packages by mark-hahn at https://atom.io/users/mark-hahn/packages?direction=desc&sort=downloads.