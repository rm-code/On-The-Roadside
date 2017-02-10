local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTAquireTarget = {};

function BTAquireTarget.new()
    local self = BTLeaf.new():addInstance( 'BTAquireTarget' );

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

        -- Get all characters visible to this character.
        local enemies = {};
        for i = 1, #tiles do
            local tile = tiles[i];
            if tile:isOccupied() and not tile:getCharacter():isDead() and tile:getCharacter():getFaction():getType() ~= character:getFaction():getType() then
                enemies[#enemies + 1] = tile;
            end
        end

        -- Select the closest enemy.
        local target;
        for i = 1, #enemies do
            local t = enemies[i];
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
            Log.debug( string.format( 'Target found at coordinates %d,%d', target:getPosition() ), 'BTAquireTarget' );
            blackboard.target = target;
            return true;
        end

        Log.debug( 'No target found', 'BTAquireTarget' );
        return false;
    end

    return self;
end

return BTAquireTarget;
