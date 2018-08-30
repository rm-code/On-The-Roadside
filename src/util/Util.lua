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
-- Rotates the target position by the given angle.
-- @tparam  number px     The vector's origin along the x-axis.
-- @tparam  number py     The vector's origin along the y-axis.
-- @tparam  number tx     The vector's target along the x-axis.
-- @tparam  number ty     The vector's target along the y-axis.
-- @tparam  number angle  The angle by which to rotate the vector.
-- @tparam  number factor Change the vector's magnitude.
-- @treturn number        The new target along the x-axis.
-- @treturn number        The new target along the y-axis.
--
function Util.rotateVector( px, py, tx, ty, angle, factor )
    local vx, vy = tx - px, ty - py

    factor = factor or 1
    vx = vx * factor
    vy = vy * factor

    -- Transform angle from degrees to radians.
    angle = math.rad( angle )

    local nx = vx * math.cos( angle ) - vy * math.sin( angle )
    local ny = vx * math.sin( angle ) + vy * math.cos( angle )

    return px + nx, py + ny
end

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

---
-- Wraps a value to min if it surpasses max and vice versa. If the value lies
-- between min and max it is returned.
-- @tparam  number min The minimum value to wrap to.
-- @tparam  number val The value to wrap.
-- @tparam  number max The maximum value to wrap to.
-- @treturn number     The wrapped value.
--
function Util.wrap( min, val, max )
    return val < min and max or val > max and min or val
end

---
-- Picks a random value from a tbl. Works only with sequences.
-- @tparam table tbl The table to select from.
-- @treturn The randomly picked value.
--
function Util.pickRandomValue( tbl )
    return tbl[love.math.random( #tbl )]
end

return Util
