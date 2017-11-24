---
-- Creates outlines for UI elements with correctly drawn intersections.
--
-- Make sure to always start the outline grid at coordinates [x=0, y=0], because
-- the draw function uses an offset to determine where to start drawing.
-- If the grid starts at coordinates [x=1, y=1] the outlines will be drawn in
-- the wrong place.
--
-- @module UIOutlines
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIOutlines = UIElement:subclass( 'UIOutlines' )


-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates a new UIOutlines instance.
-- @tparam  number   ox The x–coordinate at which to start drawing the outlines.
-- @tparam  number   oy The y–coordinate at which to start drawing the outlines.
-- @treturn UIOutlines The new instance.
--
function UIOutlines:initialize( px, py, ox, oy, w, h )
    UIElement.initialize( self, px, py, ox, oy, w, h )
    self.grid = {}
end

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Returns 1 if the tile exists or 0 if it doesn't.
-- @tparam  table  grid The grid to check.
-- @tparam  number x    The x coordinate in the grid.
-- @tparam  number y    The y coordinate in the grid.
-- @treturn number      Either 1 or 0.
--
local function getGridIndex( grid, x, y )
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
local function determineTile( grid, x, y )
    if -- Connected to all sides.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_nsew' )
    elseif -- Vertically connected.
        getGridIndex( grid, x - 1, y     ) == 0 and
        getGridIndex( grid, x + 1, y     ) == 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_ns' )
    elseif -- Horizontally connected.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) == 0 and
        getGridIndex( grid, x    , y + 1 ) == 0 then
            return TexturePacks.getSprite( 'ui_outlines_ew' )
    elseif -- Bottom right corner.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) == 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) == 0 then
            return TexturePacks.getSprite( 'ui_outlines_nw' )
    elseif -- Top left corner.
        getGridIndex( grid, x - 1, y     ) == 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) == 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_se' )
    elseif -- Top right corner.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) == 0 and
        getGridIndex( grid, x    , y - 1 ) == 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_sw' )
    elseif -- Bottom left corner.
        getGridIndex( grid, x - 1, y     ) == 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) == 0 then
            return TexturePacks.getSprite( 'ui_outlines_ne' )
    elseif -- T-intersection down.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) == 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_sew' )
    elseif -- T-intersection up.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) == 0 then
            return TexturePacks.getSprite( 'ui_outlines_new' )
    elseif -- T-intersection right.
        getGridIndex( grid, x - 1, y     ) == 0 and
        getGridIndex( grid, x + 1, y     ) ~= 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
            return TexturePacks.getSprite( 'ui_outlines_nse' )
    elseif -- T-intersection left.
        getGridIndex( grid, x - 1, y     ) ~= 0 and
        getGridIndex( grid, x + 1, y     ) == 0 and
        getGridIndex( grid, x    , y - 1 ) ~= 0 and
        getGridIndex( grid, x    , y + 1 ) ~= 0 then
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
function UIOutlines:add( x, y )
    self.grid[x] = self.grid[x] or {}
    self.grid[x][y] = true
end

---
-- Iterates over all tiles in the grid and replaces their original boolen
-- value with a sprite index based on their neighbours.
--
function UIOutlines:refresh()
    for x, line in pairs( self.grid ) do
        for y, _ in pairs( line ) do
            self.grid[x][y] = determineTile( self.grid, x, y )
        end
    end
end

---
-- Draws the outlines at the specified position.
--
function UIOutlines:draw()
    local tw, th = TexturePacks.getTileDimensions()

    TexturePacks.setColor( 'ui_outlines' )
    for x, line in pairs( self.grid ) do
        for y, sprite in pairs( line ) do
            love.graphics.draw( TexturePacks:getTileset():getSpritesheet(), sprite, (self.ax+x) * tw, (self.ay+y) * th )
        end
    end
    TexturePacks.resetColor()
end

return UIOutlines
