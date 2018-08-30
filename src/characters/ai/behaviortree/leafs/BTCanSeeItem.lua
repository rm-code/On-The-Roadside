---
-- @module BTCanSeeItem
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTCanSeeItem = BTLeaf:subclass( 'BTCanSeeItem' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTCanSeeItem:traverse( ... )
    local blackboard, character = ...

    -- Look for any items on the seen tiles.
    local items = {}
    for tile in pairs( character:getFOV() ) do
        if not tile:getInventory():isEmpty() then
            items[#items + 1] = tile
        end
    end

    -- Select the closest items.
    local target
    for i = 1, #items do
        local t = items[i]
        if not target then
            target = t
        else
            local distanceX = math.abs( target:getX() - character:getTile():getX() )
            local distanceY = math.abs( target:getY() - character:getTile():getY() )

            local ndistanceX = math.abs( t:getX() - character:getTile():getX() )
            local ndistanceY = math.abs( t:getY() - character:getTile():getY() )

            if ndistanceX + ndistanceY < distanceX + distanceY then
                target = t
            end
        end
    end

    if target then
        Log.debug( string.format( 'Item found at coordinates %d,%d', target:getPosition() ), 'BTCanSeeItem' )
        blackboard.target = target
        return true
    end

    Log.debug( 'No items found', 'BTCanSeeItem' )
    return false
end

return BTCanSeeItem
