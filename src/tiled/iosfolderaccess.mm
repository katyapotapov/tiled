/*
 * iosfolderaccess.mm
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

#include "iosfolderaccess.h"

#include "preferences.h"

#include <QDebug>
#include <QVariantMap>

#import <UIKit/UIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

using namespace Tiled;

// Maps folder paths to bookmark data
static const char kBookmarksKey[] = "Ios/FolderBookmarks";

static QVariantMap savedBookmarks()
{
    return Preferences::instance()->value(QLatin1String(kBookmarksKey)).toMap();
}

static void saveBookmarks(const QVariantMap &bookmarks)
{
    Preferences::instance()->setValue(QLatin1String(kBookmarksKey), bookmarks);
}

static NSData *createBookmark(NSURL *url)
{
    NSError *error = nil;
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&error];
    if (!bookmark)
        qWarning() << "Failed to create bookmark:" << QString::fromNSString(error.localizedDescription);
    return bookmark;
}

static UIViewController *topViewController()
{
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]])
            continue;

        for (UIWindow *window in ((UIWindowScene *) scene).windows) {
            if (!window.isKeyWindow)
                continue;

            UIViewController *controller = window.rootViewController;
            while (controller.presentedViewController)
                controller = controller.presentedViewController;
            return controller;
        }
    }
    return nil;
}

@interface TiledFolderPickerDelegate : NSObject <UIDocumentPickerDelegate>
{
@public
    std::function<void (const QString &path)> callback;
}
@end

// Keeps the delegate alive while the picker is shown (the picker only holds
// a weak reference to it)
static TiledFolderPickerDelegate *activeDelegate = nil;

@implementation TiledFolderPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    Q_UNUSED(controller)

    NSURL *url = urls.firstObject;
    auto callback = std::move(self->callback);
    activeDelegate = nil;

    if (!url)
        return;

    // Access is kept for as long as the app runs
    if (![url startAccessingSecurityScopedResource])
        qWarning() << "Failed to access" << QString::fromNSString(url.path);

    const QString path = QString::fromNSString(url.path);

    if (NSData *bookmark = createBookmark(url)) {
        QVariantMap bookmarks = savedBookmarks();
        bookmarks.insert(path, QByteArray::fromNSData(bookmark));
        saveBookmarks(bookmarks);
    }

    if (callback)
        callback(path);
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    Q_UNUSED(controller)
    activeDelegate = nil;
}

@end

namespace Tiled {
namespace IosFolderAccess {

void restoreFolders()
{
    const QVariantMap bookmarks = savedBookmarks();
    QVariantMap updatedBookmarks;

    for (auto it = bookmarks.begin(); it != bookmarks.end(); ++it) {
        BOOL stale = NO;
        NSError *error = nil;
        NSURL *url = [NSURL URLByResolvingBookmarkData:it.value().toByteArray().toNSData()
                                               options:0
                                         relativeToURL:nil
                                   bookmarkDataIsStale:&stale
                                                 error:&error];
        if (!url) {
            // The folder was most likely removed, so forget about it
            qWarning() << "Failed to restore access to" << it.key() << ":"
                       << QString::fromNSString(error.localizedDescription);
            continue;
        }

        if (![url startAccessingSecurityScopedResource])
            qWarning() << "Failed to access" << QString::fromNSString(url.path);

        NSData *bookmark = stale ? createBookmark(url) : nil;
        updatedBookmarks.insert(QString::fromNSString(url.path),
                                bookmark ? QByteArray::fromNSData(bookmark) : it.value());
    }

    if (updatedBookmarks != bookmarks)
        saveBookmarks(updatedBookmarks);
}

void pickFolder(std::function<void (const QString &path)> callback)
{
    UIViewController *presenter = topViewController();
    if (!presenter) {
        qWarning() << "No view controller to present the folder picker from";
        return;
    }

    activeDelegate = [[TiledFolderPickerDelegate alloc] init];
    activeDelegate->callback = std::move(callback);

    UIDocumentPickerViewController *picker =
            [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeFolder]];
    picker.delegate = activeDelegate;
    picker.allowsMultipleSelection = NO;

    [presenter presentViewController:picker animated:YES completion:nil];
}

} // namespace IosFolderAccess
} // namespace Tiled
