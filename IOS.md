# Editing levels on iOS

Tiled on iOS doesn't talk to GitHub itself. A git app (such as
[Working Copy](https://workingcopy.app/)) keeps a clone of the repository, and
Tiled edits the files in that clone through the Files app.

## Setup (once)

1. In the git app, sign in to GitHub and clone the repository containing the
   levels. Gusty's levels are in the `snowball` repository.
2. Make sure the clone shows up in the Files app under the git app's location.
3. In Tiled, tap **Open Folder** and pick a folder that contains both the
   levels and the files they refer to, since Tiled can only read what's inside
   the folder you picked. For gusty, pick **`data/gusty`**: its levels (in
   `levels/`) use the images in `images/`. Picking this folder rather than the
   whole repository also keeps the **Levels** list short.

Tiled opens the first `.tiled-project` it finds in that folder. When there is
none (as in snowball), it opens the folder as an unsaved project. Either way,
Tiled remembers its access to the folder across launches.

## Day to day

1. In the git app: pull.
2. In Tiled: edit and save levels as usual.
3. In the git app: review the changes, commit and push.

Avoid pulling while the same levels are open in Tiled; reopen them after a
pull to see the changes.

Levels last saved with Tiled 1.9 change a little more than expected the first
time they're saved: objects get a `"type"` instead of a `"class"` key, and an
`"opacity"` key. Gusty doesn't read either, so this is only noise in the diff.

## Touch interface

On iOS, Tiled uses a simplified interface focused on editing levels like
gusty's (one tile layer and one object layer of tile objects):

- **Levels** lists the files in the opened folder; tap one to open it.
- The tool rail on the left has **Pan**, **Paint**, **Erase** and **Fill** for
  tiles, and **Select** and **Place** for objects. Picking a tool switches to
  a layer it works on.
- Drag with two fingers to pan, and pinch to zoom. With **Pan**, one finger
  pans as well.
- Pick tiles from the tilesets at the bottom. Tool options, like flipping and
  rotating, appear next to the layer selector.
- **Properties** shows the properties of the selected object, or of the map
  when nothing is selected. **More** has Save As, Map Properties and Resize
  Map.

The same interface can be tried on the desktop by setting `TILED_MOBILE_UI=1`.

# Running in the iOS Simulator

Requirements: Xcode, [Qbs](https://qbs.io) (`brew install qbs`) and Qt for
macOS and iOS, for example installed with
[aqtinstall](https://github.com/miurahr/aqtinstall):

    uvx --from aqtinstall aqt install-qt mac desktop 6.10.3 clang_64 -O ~/Qt -m qtimageformats qtshadertools
    uvx --from aqtinstall aqt install-qt mac ios 6.10.3 ios -O ~/Qt -m qtimageformats qtshadertools

Set up a Qbs profile once. The `arm64` slice of the prebuilt Qt for iOS
only targets devices, so simulator builds are `x86_64` (they run under
Rosetta on Apple Silicon):

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    qbs setup-toolchains --detect
    qbs setup-qt ~/Qt/6.10.3/ios/bin/qmake qt-ios
    qbs config profiles.qt-ios.baseProfile xcode-iphonesimulator-x86_64

Build, then install and launch on a booted simulator:

    qbs build -d ../tiled-build-ios -p tiled profile:qt-ios config:debug
    xcrun simctl boot "iPad Pro 13-inch (M4)"
    open -a Simulator
    xcrun simctl install booted ../tiled-build-ios/debug/tiled.*/tiled.app
    xcrun simctl launch --console-pty booted org.example.tiled

On iOS, `libtiled`, `libtilededitor` and plugins are built as static libraries.
Only the JSON plugin is included, and custom commands and the scripting
`Process` object aren't available.
