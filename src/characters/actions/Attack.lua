local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );
local Bresenham = require( 'lib.Bresenham' );

local Attack = {};

function Attack.new( character, target, map )
    local self = Action.new( character:getWeapon():getAttackCost() ):addInstance( 'Attack' );

    function self:perform()
        local origin = character:getTile();

        local ox, oy = origin:getPosition();
        local tx, ty = target:getPosition();

        local range = character:getWeapon():getRange();

        Bresenham.calculateLine( ox, oy, tx, ty, function( x, y, counter )
            if counter > range then
                target = map:getTileAt( x, y );
                return false;
            end
            return true;
        end);

        Messenger.publish( 'ACTION_SHOOT', character, origin, target );

        character:removeLineOfSight();
    end

    return self;
end

return Attack;
