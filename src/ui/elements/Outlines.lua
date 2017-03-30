---
-- Creates outlines for UI elements with correctly drawn intersections.
-- @module Outlines
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Outlines = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Outlines instance.
-- @treturn Outlines The new instance.
--
function Outlines.new()
    local self = Object.new():addInstance( 'Outlines' )

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local grid = {}
    local tileset = TexturePacks.getTileset()
    local tw, th = tileset:getTileDimensions()

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Returns 1 if the tile exists or 0 if it doesn't.
    -- @tparam  number x The x coordinate in the grid.
    -- @tparam  number y The y coordinate in the grid.
    -- @treturn number   Either 1 or 0.
    --
    local function getGridIndex( x, y )
        if not grid[x] or not grid[x][y] then
            return 0
        end
        return 1
    end

    ---
    -- Checks the NSEW tiles around the given coordinates in the grid and returns
    -- an index for the appropriate sprite to use.
    -- @tparam  number x The x coordinate in the grid.
    -- @tparam  number y The y coordinate in the grid.
    -- @treturn number   The sprite index.
    --
    local function determineTile( x, y )
        if -- Connected to all sides.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 198
        elseif -- Vertically connected.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 180
        elseif -- Horizontally connected.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 197
        elseif -- Bottom right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 218
        elseif -- Top left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 219
        elseif -- Top right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 192
        elseif -- Bottom left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 193
        elseif -- T-intersection down.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 195
        elseif -- T-intersection up.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 194
        elseif -- T-intersection right.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 196
        elseif -- T-intersection left.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 181
        end
        return 1
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds a new tile to the grid.
    -- @tparam number x The x coordinate to place the tile at.
    -- @tparam number y The y coordinate to place the tile at.
    --
    function self:add( x, y )
        grid[x] = grid[x] or {}
        grid[x][y] = true
    end

    ---
    -- Iterates over all tiles in the grid and replaces their original boolen
    -- value with a sprite index based on their neighbours.
    --
    function self:refresh()
        for x, line in pairs( grid ) do
            for y, _ in pairs( line ) do
                grid[x][y] = determineTile( x, y )
            end
        end
    end

    ---
    -- Draws the outlines at the specified position.
    -- @tparam number px The x coordinate to draw the outline grid from.
    -- @tparam number py The y coordinate to draw the outline grid from.
    --
    function self:draw( px, py )
        love.graphics.setColor( COLORS.DB15 )
        for x, line in pairs( grid ) do
            for y, sprite in pairs( line ) do
                love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( sprite ), px + x * tw, py + y * th )
            end
        end
        love.graphics.setColor( COLORS.RESET )
    end

    return self
end

return Outlines
