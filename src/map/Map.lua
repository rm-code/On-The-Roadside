local Object = require( 'src.Object' );
local Square = require( 'src.map.Square' );

local Floor = require( 'src.map.worldobjects.Floor' );
local Wall  = require( 'src.map.worldobjects.Wall' );
local Door  = require( 'src.map.worldobjects.Door' );

local DIRECTION = require( 'src.enums.Direction' );

local Map = {};

function Map.new()
    local self = Object.new():addInstance( 'Map' );

    local squares;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    local function createWorldObject( type )
        if type == '.' then
            return Floor.new( true );
        elseif type == '#' then
            return Wall.new( false );
        elseif type == '+' then
            return Door.new( false );
        end
    end

    local function createSquares( grid )
        local newSquares = {};
        for x = 1, #grid do
            for y = 1, #grid[x] do
                newSquares[x] = newSquares[x] or {};
                newSquares[x][y] = Square.new( x, y, createWorldObject( grid[x][y] ));
            end
        end
        return newSquares;
    end

    ---
    -- Gives each tile a reference to its neighbours.
    --
    local function addNeighbours()
        for x = 1, #squares do
            for y = 1, #squares[x] do
                local neighbours = {};

                neighbours[DIRECTION.NORTH]      = self:getTileAt( x    , y - 1 );
                neighbours[DIRECTION.SOUTH]      = self:getTileAt( x    , y + 1 );
                neighbours[DIRECTION.NORTH_EAST] = self:getTileAt( x + 1, y - 1 );
                neighbours[DIRECTION.NORTH_WEST] = self:getTileAt( x - 1, y - 1 );
                neighbours[DIRECTION.SOUTH_EAST] = self:getTileAt( x + 1, y + 1 );
                neighbours[DIRECTION.SOUTH_WEST] = self:getTileAt( x - 1, y + 1 );
                neighbours[DIRECTION.EAST]       = self:getTileAt( x + 1, y     );
                neighbours[DIRECTION.WEST]       = self:getTileAt( x - 1, y     );

                squares[x][y]:setNeighbours( neighbours );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        -- TODO Replace
        local grid = require( 'res.data.maps.example' );
        squares = createSquares( grid );
        addNeighbours();
    end

    function self:iterate( callback )
        for x = 1, #squares do
            for y = 1, #squares[x] do
                callback( squares[x][y], x, y );
            end
        end
    end

    ---
    -- Resets the visibility flags for all visible tiles in the map.
    --
    function self:resetVisibility()
        self:iterate( function( tile )
            if tile:isVisible() then
                tile:setVisible( false );
                tile:setDirty( true );
            end
        end)
    end

    ---
    -- Cast rays in a 360° radius and marks tiles visible.
    --
    function self:calculateVisibility( tile )
        local tx, ty = tile:getPosition();

        for i = 1, 360 do
            local ox, oy = tx + 0.5, ty + 0.5;
            local rad    = math.rad( i );
            local rx, ry = math.cos( rad ), math.sin( rad );

            for _ = 1, 10 do
                local target = squares[math.floor( ox )][math.floor( oy )];
                target:setVisible( true );
                target:setExplored( true );
                target:setDirty( true ); -- Mark tile for updating.
                if not target:getWorldObject():isPassable() then
                    break;
                end
                ox = ox + rx;
                oy = oy + ry;
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getTileAt( x, y )
        return squares[x] and squares[x][y];
    end

    return self;
end

return Map;
