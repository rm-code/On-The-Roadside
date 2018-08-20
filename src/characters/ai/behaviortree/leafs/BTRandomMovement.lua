---
-- @module BTRandomMovement
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local PathFinder = require( 'src.characters.pathfinding.PathFinder' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTRandomMovement = BTLeaf:subclass( 'BTRandomMovement' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function generatePath( target, character )
    if target and target:isPassable() and not target:hasCharacter() then
        return PathFinder.generatePath( character:getTile(), target, character:getStance() )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTRandomMovement:traverse( ... )
    local _, character = ...

    local tiles = {}

    -- Get the character's FOV and store the tiles in a sequence for easier access.
    for tile in pairs( character:getFOV() ) do
        tiles[#tiles + 1] = tile
    end

    local target = Util.pickRandomValue( tiles )
    if target and target:isPassable() and not target:hasCharacter() then
        local path = generatePath( target, character )
        if path then
            local success = path:generateActions( character )
            if success then
                Log.debug( 'Character moves to target.', 'BTRandomMovement' )
                return true
            end
        end
        Log.debug( 'Can not find a path to the target', 'BTRandomMovement' )
        return false
    end

    Log.debug( 'Invalid target', 'BTRandomMovement' )
    return false
end

return BTRandomMovement
