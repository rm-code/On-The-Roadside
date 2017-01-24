local Object = require( 'src.Object' );
local Tileset = require( 'src.ui.Tileset' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryOutlines = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryOutlines.new()
    local self = Object.new():addInstance( 'InventoryOutlines' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local grid;
    local w, h, sx, sy, itemDescriptionSpacer;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Returns the value of the grid for this position or 0 for coordinates
    -- outside of the grid.
    -- @param x (number) The x coordinate in the grid.
    -- @param y (number) The y coordinate in the grid.
    -- @return  (number) The grid index or 0.
    --
    local function getGridIndex( x, y )
        if not grid[x] then
            return 0;
        elseif not grid[x][y] then
            return 0;
        end
        return grid[x][y];
    end

    ---
    -- Checks the NSEW tiles around the given coordinates in the grid and returns
    -- an index for the appropriate sprite to use.
    -- @param x (number) The x coordinate in the grid.
    -- @param y (number) The y coordinate in the grid.
    -- @return  (number) The sprite index.
    --
    local function determineTile( x, y )
        if -- Connected to all sides.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 198;
        elseif -- Vertically connected.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 180;
        elseif -- Horizontally connected.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 197;
        elseif -- Bottom right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 218;
        elseif -- Top left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 219;
        elseif -- Top right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 192;
        elseif -- Bottom left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 193;
        elseif -- T-intersection down.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 195;
        elseif -- T-intersection up.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 194;
        elseif -- T-intersection right.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 196;
        elseif -- T-intersection left.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 181;
        end
        return 1;
    end

    local function fillGrid()
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                grid[x] = grid[x] or {};
                grid[x][y] = 0;

                -- Draw screen borders.
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    grid[x][y] = 1;
                end

                -- Draw vertical column lines.
                if ( x == 1 + sx or x == 1 + 2 * sx ) and ( y < 2 * sy ) then
                    grid[x][y] = 1;
                end

                -- Draw bottom line of the column headers.
                if y == 2 then
                    grid[x][y] = 1;
                end

                -- Draw the horizontal line below the inventory columns.
                if y == 2 * sy then
                    grid[x][y] = 1;
                end

                -- Draw item description separator.
                if x == itemDescriptionSpacer and y > 2 * sy then
                    grid[x][y] = 1;
                end

                if x < itemDescriptionSpacer and y == ( 2 * sy + 2 ) then
                    grid[x][y] = 1;
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nw, nh, nsx, nsy, nitemDescriptionSpacer )
        w, h, sx, sy, itemDescriptionSpacer = nw, nh, nsx, nsy, nitemDescriptionSpacer;
        grid = {};
        fillGrid( w, h, sx, sy );
    end

    function self:draw()
        local ts = Tileset.getTileset();

        love.graphics.setColor( COLORS.DB22 );

        -- Draw horizontal lines.
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                if grid[x][y] ~= 0 then
                    love.graphics.draw( ts, Tileset.getSprite( determineTile( x, y )), x * TILE_SIZE, y * TILE_SIZE );
                end
            end
        end
    end

    return self;
end

return InventoryOutlines;
