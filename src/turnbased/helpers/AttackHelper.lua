local Attack = require( 'src.characters.actions.Attack' );
local Bresenham = require( 'lib.Bresenham' );
local LineOfSight = require( 'src.characters.LineOfSight' );

local AttackHelper = {};

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

function AttackHelper.request( map, target, character, states )
    if not character:hasLineOfSight() then
        generateLineOfSight( target, character, map );
    elseif target ~= character:getLineOfSight():getTarget() then
        character:clearActions();
        character:removePath();
        character:removeLineOfSight();
        generateLineOfSight( target, character, map );
    else
        generateAttack( target, character );
        states:push( 'execution' );
    end
end

function AttackHelper.getType()
    return 'attack';
end

return AttackHelper;
