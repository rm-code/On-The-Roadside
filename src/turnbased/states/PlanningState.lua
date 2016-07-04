local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local MovementHelper = require( 'src.turnbased.helpers.MovementHelper' );
local InteractionHelper = require( 'src.turnbased.helpers.InteractionHelper' );
local AttackHelper = require( 'src.turnbased.helpers.AttackHelper' );
local FactionManager = require( 'src.characters.FactionManager' );

local PlanningState = {};

function PlanningState.new( stateManager )
    local self = State.new();

    local map;
    local activeHelper = MovementHelper;

    function self:enter( nmap )
        map = nmap;
    end

    function self:keypressed( key )
        if key == 'right' then
            FactionManager.getCurrentCharacter():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            FactionManager.getCurrentCharacter():getWeapon():selectPrevFiringMode();
        elseif key == 'r' then
            FactionManager.getCurrentCharacter():enqueueAction( Reload.new( FactionManager.getCurrentCharacter() ));
            stateManager:push( 'execution' );
        elseif key == 'a' then
            activeHelper = AttackHelper;
        elseif key == 'e' then
            activeHelper = InteractionHelper;
        elseif key == 'm' then
            activeHelper = MovementHelper;
        elseif key == 'space' then
            FactionManager.nextCharacter();
        elseif key == 'backspace' then
            FactionManager.prevCharacter();
        elseif key == 'return' then
            FactionManager.nextFaction();
        end
    end

    function self:selectTile( tile, button )
        if not tile then
            return;
        end

        if button == 2 then
            FactionManager.selectCharacter( tile );
            return;
        end

        activeHelper.request( map, tile, FactionManager.getCurrentCharacter(), stateManager );
    end

    return self;
end

return PlanningState;
