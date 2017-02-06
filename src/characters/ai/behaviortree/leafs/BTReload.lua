local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local Reload = require( 'src.characters.actions.Reload' );

local BTReload = {};

function BTReload.new()
    local self = BTLeaf.new():addInstance( 'BTReload' );

    function self:traverse( ... )
        Log.info( 'BTReload' );
        local _, character, states, factions = ...;

        character:enqueueAction( Reload.new( character ));
        states:push( 'execution', factions, character );

        return true;
    end

    return self;
end

return BTReload;
