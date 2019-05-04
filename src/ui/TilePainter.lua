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

-- ------------------------------------------------
-- Constructor
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

return TilePainter
