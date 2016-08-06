local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local StandUp = require( 'src.characters.actions.StandUp' );
local Crouch = require( 'src.characters.actions.Crouch' );
local LieDown = require( 'src.characters.actions.LieDown' );
local MovementHelper = require( 'src.turnbased.helpers.MovementHelper' );
local InteractionHelper = require( 'src.turnbased.helpers.InteractionHelper' );
local AttackHelper = require( 'src.turnbased.helpers.AttackHelper' );
local FactionManager = require( 'src.characters.FactionManager' );
-- TODO Proper grenade implementation.
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local MousePointer = require( 'src.ui.MousePointer' );

local PlanningState = {};

function PlanningState.new( stateManager )
    local self = State.new():addInstance( 'PlanningState' );

    local map;
    local activeHelper = MovementHelper;

    function self:enter( nmap )
        map = nmap;
    end

    function self:keypressed( key )
        local character = FactionManager.getFaction():getCurrentCharacter();

        if key == 'right' then
            character:getEquipment():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            character:getEquipment():getWeapon():selectPrevFiringMode();
        elseif key == 'c' then
            character:clearActions();
            character:enqueueAction( Crouch.new( character ));
            stateManager:push( 'execution' );
        elseif key == 's' then
            character:clearActions();
            character:enqueueAction( StandUp.new( character ));
            stateManager:push( 'execution' );
        elseif key == 'p' then
            character:clearActions();
            character:enqueueAction( LieDown.new( character ));
            stateManager:push( 'execution' );
        elseif key == 'r' then
            character:clearActions();
            character:enqueueAction( Reload.new( character ));
            stateManager:push( 'execution' );
        elseif key == 'g' then
            -- TODO Proper grenade implementation.
            ExplosionManager.register( map:getTileAt( MousePointer.getGridPosition() ), love.math.random( 5, 10 ));
            stateManager:push( 'execution' );
        elseif key == 'a' then
            character:clearActions();
            activeHelper = AttackHelper;
        elseif key == 'e' then
            character:clearActions();
            activeHelper = InteractionHelper;
        elseif key == 'm' then
            character:clearActions();
            activeHelper = MovementHelper;
        elseif key == 'space' then
            activeHelper = MovementHelper;
            FactionManager.getFaction():nextCharacter();
        elseif key == 'backspace' then
            activeHelper = MovementHelper;
            FactionManager.getFaction():prevCharacter();
        elseif key == 'return' then
            activeHelper = MovementHelper;
            FactionManager.nextFaction();
        end
    end

    function self:selectTile( tile, button )
        if not tile then
            return;
        end

        if button == 2 and tile:isOccupied() then
            FactionManager.getFaction():selectCharacter( tile:getCharacter() );
            return;
        end

        activeHelper.request( map, tile, FactionManager.getFaction():getCurrentCharacter(), stateManager );
    end

    function self:getHelperType()
        return activeHelper.getType();
    end

    return self;
end

return PlanningState;
