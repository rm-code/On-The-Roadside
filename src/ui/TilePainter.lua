---
-- @module TilePainter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TilePainter = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )
local COLORS = {
    [FACTIONS.ALLIED] = {
        ACTIVE   = 'allied_active',
        INACTIVE = 'allied_inactive'
    },
    [FACTIONS.ENEMY] = {
        ACTIVE   = 'enemy_active',
        INACTIVE = 'enemy_inactive'
    },
    [FACTIONS.NEUTRAL] = {
        ACTIVE   = 'neutral_active',
        INACTIVE = 'neutral_inactive'
    },
}

local DIRECTION = require( 'src.constants.DIRECTION' )

local CONNECTION_BITMASK = {
    [0]  = 'default',

    -- Straight connections-
    [1]  = 'vertical', -- North
    [4]  = 'vertical', -- South
    [5]  = 'vertical', -- North South
    [2]  = 'horizontal', -- East
    [8]  = 'horizontal', -- West
    [10] = 'horizontal', -- East West

    -- Corners.
    [3]  = 'ne',
    [9]  = 'nw',
    [6]  = 'se',
    [12] = 'sw',

    -- T Intersection
    [7]  = 'nes',
    [11] = 'new',
    [13] = 'nws',
    [14] = 'sew',

    -- + Intersection
    [15] = 'news',
}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Selects the sprite for drawing a character.
-- @tparam  Character character The character to choose a sprite for.
-- @treturn Quad                A quad pointing to the sprite on the active tileset.
--
local function selectCharacterTile( character )
    return TexturePacks.getSprite( character:getCreatureClass(), character:getStance() )
end

---
-- Checks wether there is an adjacent world object with a group that matches the
-- connections of the original world object.
-- @tparam  table  connections The connections table containing the groups the world object connects to.
-- @tparam  Tile   neighbour   The neighbouring tile to check for a matching world object.
-- @tparam  number value       The value to return in case the world object matches.
-- @treturn number             The value indicating a match (0 if the world object doesn't match).
--
local function checkConnection( connections, neighbour, value )
    if neighbour then
        local group = neighbour:getGroup()
        if group then
            for i = 1, #connections do
                if connections[i] == group then
                    return value
                end
            end
        end
    end
    return 0
end

---
-- Selects the sprite to use for drawing a worldObject.
-- @tparam  WorldObject worldObject The worldObject to pick a sprite for.
-- @treturn Quad                    A quad pointing to the sprite on the active tileset.
--
local function selectWorldObjectSprite( worldObject )
    if worldObject:isOpenable() then
        if worldObject:isPassable() then
            return TexturePacks.getSprite( worldObject:getID(), 'open' )
        else
            return TexturePacks.getSprite( worldObject:getID(), 'closed' )
        end
    end

    -- Check if the world object sprite connects to adjacent sprites.
    local connections = worldObject:getConnections()
    if connections then
        local result = checkConnection( connections, worldObject:getNeighbour( DIRECTION.NORTH ), 1 ) +
                       checkConnection( connections, worldObject:getNeighbour( DIRECTION.EAST  ), 2 ) +
                       checkConnection( connections, worldObject:getNeighbour( DIRECTION.SOUTH ), 4 ) +
                       checkConnection( connections, worldObject:getNeighbour( DIRECTION.WEST  ), 8 )
        return TexturePacks.getSprite( worldObject:getID(), CONNECTION_BITMASK[result] )
    end

    return TexturePacks.getSprite( worldObject:getID() )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Selects a color which to use when a tile is drawn based on its contents.
-- @tparam  Tile        tile                The tile to choose a color for.
-- @tparam  WorldObject worldObject         The worldobject to choose a color for.
-- @tparam  Character   character           A character to choose a color for.
-- @tparam  boolean     worldObjectsVisible Wether or not to hide world objects.
-- @tparam  Faction     faction             The faction to draw for.
-- @treturn table                           A table containing RGBA values.
--
function TilePainter.selectTileColor( tile, worldObject, character, worldObjectsVisible, faction )
    -- Check if the specified faction can see the tile.
    if faction then
        -- Dim tiles hidden from the faction.
        if not tile:isSeenBy( faction:getType() ) then
            return TexturePacks.getColor( 'tile_unseen' )
        end

        -- Highlight activated character.
        if character == faction:getCurrentCharacter() then
            return TexturePacks.getColor( COLORS[character:getFaction():getType()].ACTIVE )
        end
    end

    if character then
        return TexturePacks.getColor( COLORS[character:getFaction():getType()].INACTIVE )
    end

    if not tile:getInventory():isEmpty() then
        local items = tile:getInventory():getItems()
        return TexturePacks.getColor( items[1]:getID() )
    end

    if worldObjectsVisible and worldObject then
        return TexturePacks.getColor( worldObject:getID() )
    end

    return TexturePacks.getColor( tile:getID() )
end

---
-- Selects a sprite from the tileset based on the contents of a tile.
-- @tparam  Tile        tile                The tile to choose a sprite for.
-- @tparam  WorldObject worldObject         The worldObject to choose a sprite for.
-- @tparam  Character   character           A character to choose a sprite for.
-- @tparam  boolean     worldObjectsVisible Wether or not to hide world objects.
-- @tparam  Faction     faction             The faction to draw for.
-- @treturn Quad                            A quad pointing to a sprite on the tileset.
--
function TilePainter.selectTileSprite( tile, worldObject, character, worldObjectsVisible, faction )
    if character and tile:isSeenBy( faction:getType() ) then
        return selectCharacterTile( character )
    end

    if not tile:getInventory():isEmpty() then
        local items = tile:getInventory():getItems()
        return TexturePacks.getSprite( items[1]:getID() )
    end

    if worldObjectsVisible and worldObject then
        return selectWorldObjectSprite( worldObject )
    end

    return TexturePacks.getSprite( tile:getID() )
end

return TilePainter
