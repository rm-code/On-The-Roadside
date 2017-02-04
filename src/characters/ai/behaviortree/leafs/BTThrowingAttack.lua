local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );
local Rearm = require( 'src.characters.actions.Rearm' );

local BTThrowingAttack = {};

function BTThrowingAttack.new()
    local self = BTLeaf.new():addInstance( 'BTThrowingAttack' );

    function self:traverse( ... )
        print( 'BTThrowingAttack' );
        local blackboard, character, states = ...;

        character:enqueueAction( ThrowingAttack.new( character, blackboard.target ));

        local weapon = character:getBackpack():getInventory():getWeapon();
        if weapon then
            character:enqueueAction( Rearm.new( character, weapon:getID() ));
        end

        states:push( 'execution', character );

        return true;
    end

    return self;
end

return BTThrowingAttack;
