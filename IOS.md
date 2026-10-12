# Editing levels on iOS

Tiled on iOS doesn't talk to GitHub itself. A git app (such as
[Working Copy](https://workingcopy.app/)) keeps a clone of the repository, and
Tiled edits the files in that clone through the Files app.

## Setup (once)

1. In the git app, sign in to GitHub and clone the repository (e.g. `gusty`).
2. Make sure the clone shows up in the Files app under the git app's location.
3. In Tiled, choose **File > Open Folder...** and pick the **root of the
   repository**, not a subfolder. Levels can refer to files elsewhere in the
   repository (gusty's levels use `../images/*.png`), and Tiled can only
   read what's inside the folder you picked.

Tiled opens the first `.tiled-project` it finds in that folder (for gusty,
`levels/gusty.tiled-project`), and remembers its access to the folder across
launches.

## Day to day

1. In the git app: pull.
2. In Tiled: edit and save levels as usual.
3. In the git app: review the changes, commit and push.

Avoid pulling while the same levels are open in Tiled; reopen them after a
pull to see the changes.
