---
-- @module Util
--

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Util = {}

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Gets all tiles within a certain radius around the center tile.
-- @tparam  Map    map        The map to get the tiles from.
-- @tparam  Tile   centerTile The center of the circle around which to get the tiles.
-- @tparam  number radius     The radius in which to get the tiles.
-- @treturn table             A sequence containing all tiles in the circle.
--
function Util.getTilesInCircle( map, centerTile, radius )
    local list = {}

    -- Get all tiles in the rectangle around the centerTile.
    for x = centerTile:getX() - radius, centerTile:getX() + radius do
        for y = centerTile:getY() - radius, centerTile:getY() + radius do
            local tile = map:getTileAt( x, y )
            if tile then
                local tx, ty = tile:getPosition()
                tx = centerTile:getX() - tx
                ty = centerTile:getY() - ty

                -- Ignore tiles which lie outside of the radius.
                if tx * tx + ty * ty <= radius * radius then
                    list[#list + 1] = tile
                end
            end
        end
    end

    return list
end

---
-- Pads a string to the right.
-- @tparam  string str    The string to right-pad.
-- @tparam  number length The required length of the string.
-- @tparam  string char   The char to use for padding.
-- @treturn string        The right padded string.
--
function Util.rightPadString( str, length, char )
    return str .. char:rep( length - #str )
end

---
-- Returns the file extension of a file.
-- @tparam  string item The file name.
-- @treturn string      The file extension.
--
function Util.getFileExtension( item )
    return item:match( '^.+(%..+)$' )
end

---
-- Clamps a value to a certain range.
-- @tparam  number min The minimum value to clamp to.
-- @tparam  number val The value to clamp.
-- @tparam  number max The maximum value to clamp to.
-- @treturn number     The clamped value.
--
function Util.clamp( min, val, max )
    return math.max( min, math.min( val, max ))
end

return Util
