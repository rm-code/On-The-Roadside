local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local MovementHelper = require( 'src.turnbased.helpers.MovementHelper' );
local InteractionHelper = require( 'src.turnbased.helpers.InteractionHelper' );
local AttackHelper = require( 'src.turnbased.helpers.AttackHelper' );
local CharacterManager = require( 'src.characters.CharacterManager' );

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
            CharacterManager.getCurrentCharacter():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            CharacterManager.getCurrentCharacter():getWeapon():selectPrevFiringMode();
        elseif key == 'r' then
            CharacterManager.getCurrentCharacter():enqueueAction( Reload.new( CharacterManager.getCurrentCharacter() ));
        elseif key == 'a' then
            activeHelper = AttackHelper;
        elseif key == 'e' then
            activeHelper = InteractionHelper;
        elseif key == 'm' then
            activeHelper = MovementHelper;
        elseif key == 'space' then
            CharacterManager.nextCharacter();
        elseif key == 'return' then
            CharacterManager.clearCharacters();
            CharacterManager.nextFaction();
        end
    end

    function self:mousepressed( mx, my, button )
        local tile = map:getTileAt( mx, my );
        if not tile then
            return;
        end

        if button == 2 then
            CharacterManager.selectCharacter( tile );
            return;
        end

        activeHelper.request( map, tile, CharacterManager.getCurrentCharacter(), stateManager );
    end

    return self;
end

return PlanningState;
