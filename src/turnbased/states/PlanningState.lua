local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local StandUp = require( 'src.characters.actions.StandUp' );
local Crouch = require( 'src.characters.actions.Crouch' );
local LieDown = require( 'src.characters.actions.LieDown' );
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
            FactionManager.getCurrentCharacter():getEquipment():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            FactionManager.getCurrentCharacter():getEquipment():getWeapon():selectPrevFiringMode();
        elseif key == 'c' then
            FactionManager.getCurrentCharacter():clearActions();
            FactionManager.getCurrentCharacter():enqueueAction( Crouch.new( FactionManager.getCurrentCharacter() ));
            stateManager:push( 'execution' );
        elseif key == 's' then
            FactionManager.getCurrentCharacter():clearActions();
            FactionManager.getCurrentCharacter():enqueueAction( StandUp.new( FactionManager.getCurrentCharacter() ));
            stateManager:push( 'execution' );
        elseif key == 'p' then
            FactionManager.getCurrentCharacter():clearActions();
            FactionManager.getCurrentCharacter():enqueueAction( LieDown.new( FactionManager.getCurrentCharacter() ));
            stateManager:push( 'execution' );
        elseif key == 'r' then
            FactionManager.getCurrentCharacter():clearActions();
            FactionManager.getCurrentCharacter():enqueueAction( Reload.new( FactionManager.getCurrentCharacter() ));
            stateManager:push( 'execution' );
        elseif key == 'a' then
            FactionManager.getCurrentCharacter():clearActions();
            activeHelper = AttackHelper;
        elseif key == 'e' then
            FactionManager.getCurrentCharacter():clearActions();
            activeHelper = InteractionHelper;
        elseif key == 'm' then
            FactionManager.getCurrentCharacter():clearActions();
            activeHelper = MovementHelper;
        elseif key == 'space' then
            activeHelper = MovementHelper;
            FactionManager.nextCharacter();
        elseif key == 'backspace' then
            activeHelper = MovementHelper;
            FactionManager.prevCharacter();
        elseif key == 'return' then
            activeHelper = MovementHelper;
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
