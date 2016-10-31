local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );
local Messenger = require( 'src.Messenger' );
local Bresenham = require( 'lib.Bresenham' );

local ThrowingAttack = {};

function ThrowingAttack.new( character, target )
    local self = Action.new( character:getInventory():getWeapon():getAttackCost(), target ):addInstance( 'ThrowingAttack' );

    function self:perform()
        -- TODO: Fix grenades.
        if true then
            return;
        end

        -- Pick the actual target based on the weapon's range attribute.
        local ox, oy = character:getTile():getPosition();
        local tx, ty = target:getPosition();

        local actualTarget;
        Bresenham.calculateLine( ox, oy, tx, ty, function( cx, cy, count )
            if count > character:getInventory():getWeapon():getRange() then
                return false;
            end
            actualTarget = character:getMap():getTileAt( cx, cy );
            return true;
        end);

        Messenger.publish( 'START_ATTACK', actualTarget );
        local package = ProjectileQueue.new( character, actualTarget );
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return ThrowingAttack;
