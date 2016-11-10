local Action = require('src.characters.actions.Action');
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

local OpenInventory = {};

function OpenInventory.new( character, target )
    local self = Action.new( 0, target ):addInstance( 'OpenInventory' );

    function self:perform()
        ScreenManager.push( 'inventory', character, target );
        return true;
    end

    return self;
end

return OpenInventory;
