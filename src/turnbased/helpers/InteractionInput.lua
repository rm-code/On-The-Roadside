local Object = require( 'src.Object' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );

local InteractionInput = {};

function InteractionInput.new( stateManager )
    local self = Object.new():addInstance( 'InteractionInput' );

    function self:request( ... )
        local target, character = ...;

        if target:hasWorldObject() then
            if target:getWorldObject():isOpenable() and target:isAdjacent( character:getTile() ) then
                if target:isPassable() then
                    character:enqueueAction( Close.new( character, target ));
                else
                    character:enqueueAction( Open.new( character, target ));
                end
                stateManager:push( 'execution', character );
            elseif target:getWorldObject():isContainer() then
                character:enqueueAction( OpenInventory.new( character, target ));
                stateManager:push( 'execution', character );
            end
        end
    end

    return self;
end

return InteractionInput;
