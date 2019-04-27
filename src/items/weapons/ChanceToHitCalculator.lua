---
-- @module ChanceToHitCalculator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ChanceToHitCalculator = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Determines in which cardinal direction(s) a character is located in relation
-- to the target.
-- @tparam number cx The character's position along the x-axis.
-- @tparam number cy The character's position along the y-axis.
-- @tparam number tx The target's position along the x-axis.
-- @tparam number tx The target's position along the y-axis.
-- @treturn boolean True if the character is located to the north.
-- @treturn boolean True if the character is located to the south.
-- @treturn boolean True if the character is located to the east.
-- @treturn boolean True if the character is located to the west.
--
local function getCharacterDirection( cx, cy, tx, ty )
    return cy < ty, cy > ty, cx > tx, cx < tx
end

---
-- Checks if certain tile contains a world object provides cover and Returns
-- the cover penalty.
-- @tparam Tile tile The tile to check.
-- @treturn number The cover penalty.
--
local function checkDirectionForCover( tile )
    if not tile then
        return 0
    elseif tile:hasWorldObject() and tile:getWorldObject():isFullCover() then
        return 40
    elseif tile:hasWorldObject() and tile:getWorldObject():isHalfCover() then
        return 20
    end
    return 0
end

---
-- Checks if the target is protected by half or full cover.
-- @tparam Character character The character shooting the weapon.
-- @tparam Tile target The target tile.
-- @treturn number The cover penalty.
--
local function calculateCoverPenalty( character, target )
    local n, s, e, w = getCharacterDirection( character:getX(), character:getY(), target:getX(), target:getY() )
    local coverValue = 0

    if n then
        coverValue = math.max( coverValue, checkDirectionForCover( target:getNeighbour( DIRECTION.NORTH )))
    end
    if s then
        coverValue = math.max( coverValue, checkDirectionForCover( target:getNeighbour( DIRECTION.SOUTH )))
    end
    if e then
        coverValue = math.max( coverValue, checkDirectionForCover( target:getNeighbour( DIRECTION.EAST )))
    end
    if w then
        coverValue = math.max( coverValue, checkDirectionForCover( target:getNeighbour( DIRECTION.WEST )))
    end

    return coverValue
end

---
-- Calculates the chance to hit.
-- @tparam Character character The character shooting the weapon.
-- @tparam Tile target The target tile.
-- @treturn number The chance to hit.
--
function ChanceToHitCalculator.calculate( character, target )
    local chanceToHit = character:getShootingSkill()
    local coverPenalty = calculateCoverPenalty( character, target )

    Log.debug( 'Cover penalty: ' .. coverPenalty, 'ProjectilePath' )

    return chanceToHit - coverPenalty
end

return ChanceToHitCalculator
