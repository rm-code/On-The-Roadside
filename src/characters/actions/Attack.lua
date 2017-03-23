local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );
local Bresenham = require( 'lib.Bresenham' );

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( character:getWeapon():getAttackCost(), target ):addInstance( 'Attack' );

    function self:perform()
        if character:getWeapon():getMagazine():isEmpty() then
            return false;
        end

        -- Pick the actual target based on the weapon's range attribute.
        local ox, oy = character:getTile():getPosition();
        local tx, ty = target:getPosition();

        local actualTarget;
        Bresenham.line( ox, oy, tx, ty, function( cx, cy, count )
            if count > character:getWeapon():getRange() then
                return false;
            end
            actualTarget = character:getMap():getTileAt( cx, cy );
            return true;
        end);

        local package = ProjectileQueue.new( character, actualTarget );
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return Attack;
