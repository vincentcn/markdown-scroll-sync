# Package-Cop

Atom editor: Find package causing an error and more.

**Looking for the 1 of 70 packages causing double typing ...**

![Image inserted by Atom editor package auto-host-markdown-image](http://i.imgur.com/BqmnoUb.gif)

### Usage Scenarios

- Isolate package causing error with fast dedicated testing
  - Enables and disables packages like a binary search or `git bisect`
  - Testing usually does not require reloading Atom
  - Only two clicks per test
  
- Logging errors and casual testing
  - Just click when a problem happens, doesn't disturb workflow
  - On each test-report the state of every package is recorded
  - All history can be seen in one table

- Manage packages
  - Enable and disable packages with one click
  - View current loaded/activated state
  
- Package development aid
  - Reload package without reloading Atom
  - Test activation and deactivation

### Installation

Use the settings page to find and install `package-cop` or type `atom install package-cop`.

### Open the Package-Cop page

The entire UI is in one page in one tab. The command `package-cop:open` brings up this page.  The key combination `ctrl-F12` is bound to this command by default.

### Detailed UI description

Turn on help using the button at the top right of the package-cop page to see inline text decribing all UI features. That help is not duplicated here.  Note that the UI is fully functional when it is embedded in the help text.

### Using safe mode

Whenever you run into a problem, restart Atom in safe mode with the command `atom --safe`.  If the problem persists in safe mode then submit an issue to https://github.com/atom/atom.    This package will not help you in that situation.
  
### Isolate package causing error with fast dedicated testing

Detailed instructions (same as video above) ...

- When you see an error, open the package-cop page and click `Problem Occurred` and then `Test Problem (Bisect)`.  You will now see green checkmarks for each problem cleared, i.e. known to not cause the problem.

- Repeat the test, bring up the package-cop page, and click on `Problem Occurred` or `Test Passed`.  Click on `Test Problem (Bisect)` again.

- Repeat the last step multiple times and observe the results shown in the box in the upper right.  They will look like `Packages Cleared: 38/70, 52%`. You will see the progress as more packges are cleared.  When finished you should see `Package causing problem: some-evil-package` in red.  

- If you see `Packages Cleared: 70/70, 100%` in red then the overall process failed. If that happens you should start with a new problem name and after each time you click `Test Problem (Bisect)` then click on `Reload Atom`.  After the reload you will see the package-cop page again.  Repeat the test reloading Atom each time.

- If it still fails you can select the checkbox `Activate all enabled on reload` before you click on `Reload Atom`.  This will cause all packages to activate immediately upon reload and improve the accuracy of testing.

- If this still doesn't work then the problem is too complex for this method.  Maybe it relies on two packages being loaded at once.  In this case you can look at the report results on the right of the package list and maybe figure it out yourself.  See the page help for the meaning of that section.

### Logging errors and casual testing

If you are using the editor and a problem occurs, you don't have to stop immediately to test it.  Just bring up the package-cop page, enter a problem name, and click on `Problem Occurred`.  You can then go back to work.  You can do this every time the problem occurs and it only takes one click after the first time.

This not only creates a log of the problems, but it also calculates which packages are cleared with whatever information it has.  Green marks will appear for each cleared package.  If you enable and disable packages every so often then more packages will be cleared.  You may find the cause without ever doing specific testing.

This can be done for multiple projects by clicking on the problem name before reporting the error.

### Test report buttons

You might have noticed the fail button is labeled `Problem Occurred` instead of `Test Failed` to match the button `Test Passed`.  This is because reporting a failure is fundamentally different than passing a specific test.  It may be surprising but you can isolate a bad package without ever using `Test Passed`.  While this may be slower it will be more accurate since you never know with complete confidence a test is accurate.  But you do know exactly when a problem occurs.

### License

Package-Cop is copyright Mark Hahn using the MIT license.

