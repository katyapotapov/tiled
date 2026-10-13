/*
 * pantool.h
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

#include "abstracttool.h"

namespace Tiled {

/**
 * A tool that pans the map view when dragging. Mostly useful on touch
 * screens, where there is no middle mouse button or space bar.
 */
class PanTool : public AbstractTool
{
    Q_OBJECT

public:
    explicit PanTool(QObject *parent = nullptr);

    void activate(MapScene *scene) override;
    void deactivate(MapScene *scene) override;

    void mouseEntered() override {}
    void mouseLeft() override {}
    void mouseMoved(const QPointF &, Qt::KeyboardModifiers) override {}
    void mousePressed(QGraphicsSceneMouseEvent *) override {}
    void mouseReleased(QGraphicsSceneMouseEvent *) override {}

    void languageChanged() override;

private:
    static void setPanning(MapScene *scene, bool enabled);
};

} // namespace Tiled
