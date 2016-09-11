local Object = require( 'src.Object' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );

local InteractionInput = {};

function InteractionInput.new( stateManager )
    local self = Object.new():addInstance( 'InteractionInput' );

    function self:request( ... )
        local target, character = unpack{ ... };

        if target:hasWorldObject() and target:getWorldObject():isOpenable() and target:isAdjacent( character:getTile() ) then
            if target:isPassable() then
                character:enqueueAction( Close.new( character, target ));
            else
                character:enqueueAction( Open.new( character, target ));
            end
            stateManager:push( 'execution', character );
        end
    end

    return self;
end

return InteractionInput;
