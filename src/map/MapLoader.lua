---
-- This module handles the loading of a map from a savefile and creating an
-- actual Map object.
-- @module MapLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local Map = require( 'src.map.Map' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapLoader = Class( 'MapLoader' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Recreates the worldObject layer from a saved map and places it on a new map
-- instance.
-- @tparam Map   map          The map instance to place the worldObjects on.
-- @tparam table worldObjects The saved data for the world objects.
--
local function loadWorldObjects( map, worldObjects )
    for _, worldObjectData in ipairs( worldObjects ) do
        -- Recreate the world object.
        local worldObject = WorldObjectFactory.create( worldObjectData.id )

        worldObject:setHitPoints( worldObjectData.hp )
        worldObject:setPassable( worldObjectData.passable )
        worldObject:setBlocksVision( worldObjectData.blocksVision )

        -- Recreate inventory if world object is a container.
        if worldObject:isContainer() and worldObjectData.inventory then
            worldObject:getInventory():loadItems( worldObjectData.inventory )
        end

        -- Place world object on the map.
        map:setWorldObjectAt( worldObjectData.x, worldObjectData.y, worldObject )
    end
end

---
-- Recreates the tile layer from a saved map and places it on a new map instance.
-- @tparam Map   map   The map instance to place the tiles on.
-- @tparam table tiles The save data for the tiles.
--
local function loadTiles( map, tiles )
    for _, tileData in ipairs( tiles ) do
        -- Recreate the tile.
        local tile = TileFactory.create( tileData.id )

        -- Recreate the tile's inventory if it had one.
        if tileData.inventory then
            tile:getInventory():loadItems( tileData.inventory )
        end

        -- Place tile on the map.
        map:setTileAt( tileData.x, tileData.y, tile )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Recreates a map from a savefile.
-- @tparam  table savedmap A table containing the saved map information.
-- @treturn Map            The loaded map instance.
--
function MapLoader:recreateMap( savedmap )
    local map = Map( savedmap.width, savedmap.height )

    loadTiles( map, savedmap.tiles )
    loadWorldObjects( map, savedmap.worldObjects )

    return map
end

return MapLoader
