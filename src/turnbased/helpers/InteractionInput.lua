---
-- @module InteractionInput
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Open = require( 'src.characters.actions.Open' )
local Close = require( 'src.characters.actions.Close' )
local OpenInventory = require( 'src.characters.actions.OpenInventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InteractionInput = Class( 'InteractionInput' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates opening or closing actions for doors depending on the current
-- state of the door.
-- @tparam Tile      target    The tile to act upon.
-- @tparam Character character The character to create the action for.
--
local function handleDoors( target, character )
    if target:isPassable() then
        character:enqueueAction( Close( character, target ))
    else
        character:enqueueAction( Open( character, target ))
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Requests a new action for a given character.
-- @tparam  Tile      target    The tile to act upon.
-- @tparam  Character character The character to create the action for.
-- @treturn boolean             True if an action was created, false otherwise.
--
function InteractionInput:request( target, character )
    -- Characters can only interact with adjacent tiles.
    if not target:isAdjacent( character:getTile() ) then
        return false
    end

    -- Handle interactions with world objects.
    if target:hasWorldObject() then
        if target:getWorldObject():isOpenable() then
            handleDoors( target, character )
            return true
        end

        if target:getWorldObject():isContainer() then
            character:enqueueAction( OpenInventory( character, target ))
            return true
        end
        return false
    end

    -- Handle interactions with other characters.
    if target:hasCharacter() then
        if target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            character:enqueueAction( OpenInventory( character, target ))
            return true
        end
        return false
    end

    -- Allow interaction with empty adjacent tiles.
    character:enqueueAction( OpenInventory( character, target ))
    return true
end

---
-- Returns the predicted ap cost for this action.
-- @tparam  Tile      target    The tile to interact with.
-- @tparam  Character character The character taking the action.
-- @treturn number              The cost.
--
function InteractionInput:getPredictedAPCost( target, character )
    if target:hasWorldObject() then
        return target:getWorldObject():getInteractionCost( character:getStance() ) or 0
    end
    return 0
end

return InteractionInput
