/*
 * iosfolderaccess.h
 * Copyright 2026, Tiled contributors
 *
 * This file is part of Tiled.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include <QString>

#include <functional>

namespace Tiled {

/**
 * On iOS, files outside the app's sandbox (like a repository cloned by a git
 * app and exposed through the Files app) can only be accessed after the user
 * picks them in the system document picker. Access to a picked folder covers
 * everything inside it, and is remembered across launches using bookmarks.
 */
namespace IosFolderAccess {

/**
 * Regains access to the folders picked in earlier runs. Needs to be called
 * before restoring the session, since it may refer to files in those folders.
 */
void restoreFolders();

/**
 * Shows the system folder picker. When the user picks a folder, access to it
 * is remembered and \a callback is called with the path of the folder.
 */
void pickFolder(std::function<void (const QString &path)> callback);

} // namespace IosFolderAccess
} // namespace Tiled
