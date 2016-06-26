local State = require( 'src.turnbased.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Attack = require( 'src.characters.actions.Attack' );
local Reload = require( 'src.characters.actions.Reload' );
local Bresenham = require( 'lib.Bresenham' );
local LineOfSight = require( 'src.characters.LineOfSight' );

local AttackState = {};

function AttackState.new( stateManager )
    local self = State.new();

    local map;

    function self:enter( params )
        map = params.map;
    end

    local function generateLineOfSight( target, character )
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
        character:enqueueAction( Attack.new( character, target, map ));
        stateManager:switch( 'execution', { map = map } );
    end

    local function checkAttack( target, character )
        if not character:hasLineOfSight() then
            generateLineOfSight( target, character );
        elseif target ~= character:getLineOfSight():getTarget() then
            character:clearActions();
            character:removePath();
            character:removeLineOfSight();
            generateLineOfSight( target, character );
        else
            generateAttack( target, character );
        end
    end

    function self:keypressed( key )
        if key == 'right' then
            CharacterManager.getCurrentCharacter():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            CharacterManager.getCurrentCharacter():getWeapon():selectPrevFiringMode();
        elseif key == 'r' then
            CharacterManager.getCurrentCharacter():enqueueAction( Reload.new( CharacterManager.getCurrentCharacter() ));
            stateManager:switch( 'execution', { map = map } );
        elseif key == 'escape' then
            stateManager:switch( 'movement', { map = map } );
        elseif key == 'space' then
            CharacterManager.nextCharacter();
        end
    end

    function self:mousepressed( mx, my, _ )
        local tile = map:getTileAt( mx, my );
        if not tile then
            return;
        end
        checkAttack( tile, CharacterManager.getCurrentCharacter() );
    end

    return self;
end

return AttackState;
