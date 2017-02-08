local State = require( 'src.turnbased.states.State' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

local MovementInput = {};

function MovementInput.new()
    local self = State.new():addInstance( 'MovementInput' );

    local path;

    local function generatePath( target, character )
        if target and not target:isOccupied() then
            path = PathFinder.generatePath( character, target, true );
        end
    end

    function self:request( ... )
        local target, character = ...;
        if not path or target ~= path:getTarget() then
            generatePath( target, character );
            return false;
        else
            path:generateActions( character );
            path = nil;
            return true;
        end
    end

    function self:hasPath()
        return path ~= nil;
    end

    function self:getPath()
        return path;
    end

    return self;
end

return MovementInput;
