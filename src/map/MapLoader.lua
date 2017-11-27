---
-- This module handles the loading of a map from a savefile and creating an
-- actual Map object.
-- @module MapLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapLoader = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapLoader.new()
    local self = Object.new():addInstance( 'MapLoader' )

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function recreateTile( x, y, id )
        return TileFactory.create( x, y, id )
    end

    local function recreateWorldObject( id, hp, passable, blocksVision, inventory )
        local worldObject = WorldObjectFactory.create( id )
        worldObject:setHitPoints( hp )
        worldObject:setPassable( passable )
        worldObject:setBlocksVision( blocksVision )
        if worldObject:isContainer() and inventory then
            worldObject:getInventory():loadItems( inventory )
        end
        return worldObject
    end

    local function loadSavedTiles( savedTiles )
        local loadedTiles = {}
        for _, tile in ipairs( savedTiles ) do
            -- Recreate the tile.
            local recreatedTile = recreateTile( tile.x, tile.y, tile.id )

            -- Recreate any worldobject that was located on the tile.
            if tile.worldObject then
                local obj = tile.worldObject
                local worldObject = recreateWorldObject( obj.id, obj.hp, obj.passable, obj.blocksVision, obj.inventory )
                recreatedTile:addWorldObject( worldObject )
            end

            -- Recreate the tile's inventory if it had one.
            if tile.inventory then
                recreatedTile:getInventory():loadItems( tile.inventory )
            end

            -- Store tile in the table.
            loadedTiles[tile.x] = loadedTiles[tile.x] or {}
            loadedTiles[tile.x][tile.y] = recreatedTile
        end
        return loadedTiles
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Recreates a map from a savefile.
    -- @tparam  table savedmap A table containing the saved map information.
    -- @treturn table          A table containing the recreated tiles and world objects.
    -- @treturn number         The width of the recreated map.
    -- @treturn number         The height of the recreated map.
    --
    function self:recreateMap( savedmap )
        return loadSavedTiles( savedmap.tiles ), savedmap.width, savedmap.height
    end

    return self
end

return MapLoader
