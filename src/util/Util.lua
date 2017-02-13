local Util = {};

---
-- Gets all tiles within a certain radius around the center tile.
-- @param centerTile (Tile)   The center of the explosion.
-- @param radius     (number) The radius in which to get the tiles.
-- @return           (table)  A sequence containing all tiles in the circle.
--
function Util.getTilesInCircle( map, centerTile, radius )
    local list = {};

    -- Get all tiles in the rectangle around the centerTile.
    for x = centerTile:getX() - radius, centerTile:getX() + radius do
        for y = centerTile:getY() - radius, centerTile:getY() + radius do
            local tile = map:getTileAt( x, y );
            if tile then
                local tx, ty = tile:getPosition();
                tx = centerTile:getX() - tx;
                ty = centerTile:getY() - ty;

                -- Ignore tiles which lie outside of the radius.
                if tx * tx + ty * ty <= radius * radius then
                    list[#list + 1] = tile;
                end
            end
        end
    end

    return list;
end

return Util;