---
-- Creates outlines for UI elements with correctly drawn intersections.
--
-- Make sure to always start the outline grid at coordinates [x=0, y=0], because
-- the draw function uses an offset to determine where to start drawing.
-- If the grid starts at coordinates [x=1, y=1] the outlines will be drawn in
-- the wrong place.
--
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
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Outlines instance.
-- @tparam  number   ox The x–coordinate at which to start drawing the outlines.
-- @tparam  number   oy The y–coordinate at which to start drawing the outlines.
-- @treturn Outlines The new instance.
--
function Outlines.new( ox, oy )
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
                return TexturePacks.getSprite( 'ui_outlines_nsew' )
        elseif -- Vertically connected.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_ns' )
        elseif -- Horizontally connected.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return TexturePacks.getSprite( 'ui_outlines_ew' )
        elseif -- Bottom right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return TexturePacks.getSprite( 'ui_outlines_nw' )
        elseif -- Top left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_se' )
        elseif -- Top right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_sw' )
        elseif -- Bottom left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return TexturePacks.getSprite( 'ui_outlines_ne' )
        elseif -- T-intersection down.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_sew' )
        elseif -- T-intersection up.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return TexturePacks.getSprite( 'ui_outlines_new' )
        elseif -- T-intersection right.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_nse' )
        elseif -- T-intersection left.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return TexturePacks.getSprite( 'ui_outlines_nsw' )
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
    --
    function self:draw()
        TexturePacks.setColor( 'ui_outlines' )
        for x, line in pairs( grid ) do
            for y, sprite in pairs( line ) do
                love.graphics.draw( tileset:getSpritesheet(), sprite, (ox+x) * tw, (oy+y) * th )
            end
        end
        TexturePacks.resetColor()
    end

    return self
end

return Outlines
