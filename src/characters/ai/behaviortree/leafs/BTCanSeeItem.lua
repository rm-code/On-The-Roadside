local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanSeeItem = {};

function BTCanSeeItem.new()
    local self = BTLeaf.new():addInstance( 'BTCanSeeItem' );

    function self:traverse( ... )
        local blackboard, character = ...;

        local tiles = {};

        -- Get the character's FOV and store the tiles in a sequence for easier access.
        local fov = character:getFOV();
        for _, rx in pairs( fov ) do
            for _, target in pairs( rx ) do
                tiles[#tiles + 1] = target;
            end
        end

        -- Look for any items on those tiles.
        local items = {};
        for i = 1, #tiles do
            local tile = tiles[i];
            if not tile:getInventory():isEmpty() then
                items[#items + 1] = tile;
            end
        end

        -- Select the closest items.
        local target;
        for i = 1, #items do
            local t = items[i];
            if not target then
                target = t;
            else
                local distanceX = math.abs( target:getX() - character:getTile():getX() );
                local distanceY = math.abs( target:getY() - character:getTile():getY() );

                local ndistanceX = math.abs( t:getX() - character:getTile():getX() );
                local ndistanceY = math.abs( t:getY() - character:getTile():getY() );

                if ndistanceX + ndistanceY < distanceX + distanceY then
                    target = t;
                end
            end
        end

        if target then
            Log.debug( string.format( 'Item found at coordinates %d,%d', target:getPosition() ), 'BTCanSeeItem' );
            blackboard.target = target;
            return true;
        end

        Log.debug( 'No items found', 'BTCanSeeItem' );
        return false;
    end

    return self;
end

return BTCanSeeItem;
