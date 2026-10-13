/*
 * pantool.cpp
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

#include "pantool.h"

#include "mapscene.h"
#include "mapview.h"

using namespace Tiled;

PanTool::PanTool(QObject *parent)
    : AbstractTool("PanTool",
                   tr("Pan"),
                   QIcon(QLatin1String(":images/22/stock-tool-move-22.png")),
                   QKeySequence(Qt::Key_H),
                   parent)
{
    setTargetLayerType(Layer::AnyLayerType);
    setCursor(Qt::OpenHandCursor);
}

void PanTool::activate(MapScene *scene)
{
    AbstractTool::activate(scene);
    setPanning(scene, true);
}

void PanTool::deactivate(MapScene *scene)
{
    setPanning(scene, false);
    AbstractTool::deactivate(scene);
}

void PanTool::languageChanged()
{
    setName(tr("Pan"));
}

void PanTool::setPanning(MapScene *scene, bool enabled)
{
    const auto views = scene->views();
    for (QGraphicsView *view : views)
        if (auto mapView = qobject_cast<MapView*>(view))
            mapView->setLeftButtonPanningEnabled(enabled);
}
