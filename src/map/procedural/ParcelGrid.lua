local Object = require( 'src.Object' )
local Parcel = require( 'src.map.procedural.Parcel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ParcelGrid = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ParcelGrid.new( w, h )
    local self = Object.new():addInstance( 'ParcelGrid' )

    local grid

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Creates empty Parcels in the grid.
    --
    local function createGrid()
        grid = {}

        -- Create the parcels in the grid.
        for x = 1, w do
            grid[x] = {}
            for y = 1, h do
                grid[x][y] = Parcel.new()
                grid[x][y]:setOccupied( false )
            end
        end
    end

    ---
    -- Gives each parcel in the grid a reference to its neighbours.
    --
    local function addNeighbours()
        for x = 1, #grid do
            for y = 1, #grid[x] do
                local neighbours = {}

                neighbours[DIRECTION.NORTH]      = self:getParcelAt( x    , y - 1 ) or false
                neighbours[DIRECTION.SOUTH]      = self:getParcelAt( x    , y + 1 ) or false
                neighbours[DIRECTION.NORTH_EAST] = self:getParcelAt( x + 1, y - 1 ) or false
                neighbours[DIRECTION.NORTH_WEST] = self:getParcelAt( x - 1, y - 1 ) or false
                neighbours[DIRECTION.SOUTH_EAST] = self:getParcelAt( x + 1, y + 1 ) or false
                neighbours[DIRECTION.SOUTH_WEST] = self:getParcelAt( x - 1, y + 1 ) or false
                neighbours[DIRECTION.EAST]       = self:getParcelAt( x + 1, y     ) or false
                neighbours[DIRECTION.WEST]       = self:getParcelAt( x - 1, y     ) or false

                grid[x][y]:setNeighbours( neighbours )
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        createGrid()
        addNeighbours()
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getWidth()
        return w
    end

    function self:getHeight()
        return h
    end

    function self:getDimensions()
        return w, h
    end

    ---
    -- Returns the Parcel at the given coordinates.
    -- @tparam  number x The position along the x-axis.
    -- @tparam  number y The position along the y-axis.
    -- @treturn Parcel   The Parcel at the given position.
    --
    function self:getParcelAt( x, y )
        return grid[x] and grid[x][y]
    end

    return self
end

return ParcelGrid
