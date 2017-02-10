local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

local BTRandomMovement = {};

function BTRandomMovement.new()
    local self = BTLeaf.new():addInstance( 'BTRandomMovement' );

    local function generatePath( target, character )
        if target and not target:isOccupied() then
            return PathFinder.generatePath( character, target, true );
        end
    end

    function self:traverse( ... )
        local _, character, states, factions = ...;

        local tiles = {};

        -- Get the character's FOV and store the tiles in a sequence for easier access.
        local fov = character:getFOV();
        for _, rx in pairs( fov ) do
            for _, target in pairs( rx ) do
                tiles[#tiles + 1] = target;
            end
        end

        local target = tiles[love.math.random( 1, #tiles )];
        if target and target:isPassable() and not target:isOccupied() then
            local path = generatePath( target, character );
            if path then
                local success = path:generateActions( character );
                if success then
                    Log.debug( 'Character moves to target.', 'BTRandomMovement' );
                    states:push( 'execution', factions, character );
                    return true;
                end
            end
            Log.debug( 'Can not find a path to the target', 'BTRandomMovement' );
        end

        Log.debug( 'Invalid target', 'BTRandomMovement' );
        return false;
    end

    return self;
end

return BTRandomMovement;
