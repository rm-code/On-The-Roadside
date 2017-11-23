local Observable = require( 'src.util.Observable' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local ItemFactory = require( 'src.items.ItemFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Map = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Map.new()
    local self = Observable.new():addInstance( 'Map' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local tiles
    local width, height
    local spawnpoints

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Gives each tile a reference to its neighbours.
    --
    local function addNeighbours()
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                local neighbours = {}

                neighbours[DIRECTION.NORTH]      = self:getTileAt( x    , y - 1 )
                neighbours[DIRECTION.SOUTH]      = self:getTileAt( x    , y + 1 )
                neighbours[DIRECTION.NORTH_EAST] = self:getTileAt( x + 1, y - 1 )
                neighbours[DIRECTION.NORTH_WEST] = self:getTileAt( x - 1, y - 1 )
                neighbours[DIRECTION.SOUTH_EAST] = self:getTileAt( x + 1, y + 1 )
                neighbours[DIRECTION.SOUTH_WEST] = self:getTileAt( x - 1, y + 1 )
                neighbours[DIRECTION.EAST]       = self:getTileAt( x + 1, y     )
                neighbours[DIRECTION.WEST]       = self:getTileAt( x - 1, y     )

                tiles[x][y]:addNeighbours( neighbours )
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the map by creating the Tiles, creating references to the
    -- neighbouring tiles and adding WorldObjects.
    --
    function self:init( ntiles, nwidth, nheight )
        tiles = ntiles
        width, height = nwidth, nheight
        addNeighbours()
    end

    ---
    -- Iterates over all tiles and performs the callback function on them.
    -- @param callback (function) The operation to perform on each tile.
    --
    function self:iterate( callback )
        for x = 1, width do
            for y = 1, height do
                callback( tiles[x][y], x, y )
            end
        end
    end

    ---
    -- Randomly searches for a tile on which a player could be spawned.
    -- @tparam  string faction The faction id to spawn a character for.
    -- @treturn Tile           A tile suitable for spawning.
    --
    function self:findSpawnPoint( faction )
        for _ = 1, 2000 do
            local index = love.math.random( #spawnpoints[faction] )
            local spawn = spawnpoints[faction][index]

            local tile = self:getTileAt( spawn.x, spawn.y )
            if tile:isPassable() and not tile:isOccupied() then
                return tile
            end
        end
        error( string.format( 'Can not find a valid spawnpoint at position!' ))
    end

    ---
    -- Updates the map. This resets the visibility attribute for all visible
    -- tiles and marks them for a drawing update. It also replaces destroyed
    -- WorldObjects with their debris types or removes them completely.
    --
    function self:update()
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                local tile = tiles[x][y]
                if tile:hasWorldObject() and tile:getWorldObject():isDestroyed() then
                    -- Create items from the destroyed object.
                    for _, drop in ipairs( tile:getWorldObject():getDrops() ) do
                        local id, tries, chance = drop.id, drop.tries, drop.chance
                        for _ = 1, tries do
                            if love.math.random( 100 ) < chance then
                                local item = ItemFactory.createItem( id )
                                tile:getInventory():addItem( item )
                            end
                        end
                    end

                    -- If the world object was a container drop the items in it.
                    if tile:getWorldObject():isContainer() and not tile:getWorldObject():getInventory():isEmpty() then
                        local items = tile:getWorldObject():getInventory():getItems()
                        for _, item in pairs( items ) do
                            tile:getInventory():addItem( item )
                        end
                    end

                    -- If the world object has a debris object, place that on the tile.
                    if tile:getWorldObject():getDebrisID() then
                        local nobj = WorldObjectFactory.create( tile:getWorldObject():getDebrisID() )
                        tile:removeWorldObject()
                        tile:addWorldObject( nobj )
                    else
                        tile:removeWorldObject()
                    end
                    self:publish( 'TILE_UPDATED', tile )
                end
            end
        end
    end

    ---
    -- Marks all tiles which have been explored by this faction as dirty.
    -- @param faction (string) The faction identifier.
    --
    function self:updateExplorationInfo( faction )
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                if tiles[x][y]:isExplored( faction ) then
                    tiles[x][y]:setDirty( true )
                end
            end
        end
    end

    function self:serialize()
        local t = {
            width = width,
            height = height,
            tiles = {}
        }

        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                table.insert( t.tiles, tiles[x][y]:serialize() )
            end
        end

        return t
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the Tile at the given coordinates.
    -- @param x (number) The position along the x-axis.
    -- @param y (number) The position along the y-axis.
    -- @return  (Tile)   The Tile at the given position.
    --
    function self:getTileAt( x, y )
        return tiles[x] and tiles[x][y]
    end

    ---
    -- Returns the map's dimensions.
    -- @treturn number The map's width.
    -- @treturn number The map's height.
    --
    function self:getDimensions()
        return width, height
    end

    function self:setSpawnpoints( nspawnpoints )
        spawnpoints = nspawnpoints
    end

    return self
end

return Map
