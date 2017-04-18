local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ThrownProjectileQueue = require( 'src.items.weapons.ThrownProjectileQueue' );
local Bresenham = require( 'lib.Bresenham' );

local ThrowingAttack = {};

function ThrowingAttack.new( character, target )
    local self = Action.new( character:getWeapon():getAttackCost(), target ):addInstance( 'ThrowingAttack' );

    function self:perform()
        -- Pick the actual target based on the weapon's range attribute.
        local ox, oy = character:getTile():getPosition();
        local tx, ty = target:getPosition();
        local th = target:getHeight()

        local ax, ay
        Bresenham.line( ox, oy, tx, ty, function( cx, cy, count )
            if count > character:getWeapon():getRange() then
                return false;
            end
            ax, ay = cx, cy
            return true;
        end);

        local package = ThrownProjectileQueue.new( character, ax, ay, th )
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return ThrowingAttack;
