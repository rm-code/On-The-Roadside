local Object = require( 'src.Object' );
local Attack = require( 'src.characters.actions.Attack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );
local Bresenham = require( 'lib.Bresenham' );
local LineOfSight = require( 'src.characters.LineOfSight' );

local AttackInput = {};

function AttackInput.new( stateManager )
    local self = Object.new():addInstance( 'AttackInput' );

    local function generateLineOfSight( target, character, map )
        local ox, oy = character:getTile():getPosition();
        local tx, ty = target:getPosition();

        local seenTiles = {};

        Bresenham.calculateLine( ox, oy, tx, ty, function( sx, sy )
            seenTiles[#seenTiles + 1] = map:getTileAt( sx, sy );
            return true;
        end)

        character:addLineOfSight( LineOfSight.new( seenTiles ));
    end

    local function generateAttack( target, character )
        character:enqueueAction( Attack.new( character, target ));
    end

    function self:request( ... )
        local target, character, map = unpack{ ... };

        if character:getEquipment():getWeapon():getWeaponType() == 'Melee' then
            character:enqueueAction( MeleeAttack.new( character, target ));
            stateManager:push( 'execution', character );
            return;
        end

        if character:hasLineOfSight() and target == character:getLineOfSight():getTarget() then
            generateAttack( target, character );
            character:removeLineOfSight();
            stateManager:push( 'execution', character );
            return;
        end

        generateLineOfSight( target, character, map );
    end

    return self;
end

return AttackInput;
