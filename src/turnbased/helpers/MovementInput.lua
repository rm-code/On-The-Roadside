local State = require( 'src.turnbased.states.State' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

local MovementInput = {};

function MovementInput.new()
    local self = State.new():addInstance( 'MovementInput' );

    local path;

    local function generatePath( target, character )
        if target and target:isPassable() and not target:isOccupied() then
            path = PathFinder.generatePath( character, target, true );
        end
    end

    function self:request( ... )
        local target, character = ...;

        if target == character:getTile() then
            return false;
        elseif not path or target ~= path:getTarget() then
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

    ---
    -- Returns the predicted ap cost for this action.
    -- @return (number) The cost.
    --
    function self:getPredictedAPCost()
        return path:getCost();
    end

    return self;
end

return MovementInput;
