---
-- @module CombatState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' );
local MapLoader = require( 'src.map.MapLoader' )
local Factions = require( 'src.characters.Factions' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local StateManager = require( 'src.turnbased.states.StateManager' )
local SadisticAIDirector = require( 'src.characters.ai.SadisticAIDirector' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CombatState = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function CombatState.new()
    local self = Object.new():addInstance( 'CombatState' )

    local map;
    local factions;
    local observations = {};

    local stateManager
    local states = {
        execution = require( 'src.turnbased.states.ExecutionState' ),
        planning  = require( 'src.turnbased.states.PlanningState' )
    }

    local sadisticAIDirector

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( savegame )
        map = MapLoader.createRandom()
        map:init( savegame );

        factions = Factions.new( map );
        factions:init()

        if savegame then
            factions:loadCharacters( savegame.factions )
        else
            factions:spawnCharacters( 10, FACTIONS.ALLIED  )
            factions:spawnCharacters(  5, FACTIONS.NEUTRAL )
            factions:spawnCharacters( 10, FACTIONS.ENEMY   )
        end

        -- Generate initial FOV for all factions.
        factions:iterate( function( faction )
            faction:iterate( function( character )
                character:generateFOV()
            end)
        end)

        stateManager = StateManager.new( states )
        stateManager:push( 'planning', factions )

        sadisticAIDirector = SadisticAIDirector.new( factions, stateManager )

        ProjectileManager.init( map );
        ExplosionManager.init( map );

        -- Register obsersvations.
        observations[#observations + 1] = map:observe( self );

        -- Free memory if possible.
        collectgarbage( 'collect' );
    end

    function self:receive( event, ... )
        if event == 'TILE_UPDATED' then
            local tile = ...;
            assert( tile:instanceOf( 'Tile' ), 'Expected an object of type Tile.' );
            factions:getFaction():regenerateFOVSelectively( tile );
        end
    end

    function self:update( dt )
        map:update();

        -- Update AI if current faction is AI controlled.
        if factions:getFaction():isAIControlled() and not stateManager:blocksInput() then
            sadisticAIDirector:update( dt )
        end
        stateManager:update( dt )

        if not factions:findFaction( FACTIONS.ALLIED ):hasLivingCharacters() then
            ScreenManager.push( 'gameover', false );
        end
        if not factions:findFaction( FACTIONS.ENEMY ):hasLivingCharacters() then
            ScreenManager.push( 'gameover', true );
        end
    end

    function self:serialize()
        local t = {
            ['gameversion'] = getVersion(),
            ['map'] = map:serialize(),
            ['factions'] = factions:serialize()
        };
        return t;
    end

    function self:close()
        ProjectileManager.clear();
        ExplosionManager.clear();
    end

    function self:getMap()
        return map;
    end

    function self:getFactions()
        return factions;
    end

    function self:keypressed( key, scancode, isrepeat )
        if factions:getFaction():isAIControlled() or stateManager:blocksInput() then
            return
        end
        stateManager:keypressed( key, scancode, isrepeat )
    end

    function self:mousepressed( mx, my, button )
        if factions:getFaction():isAIControlled() or stateManager:blocksInput() then
            return
        end
        stateManager:selectTile( map:getTileAt( mx, my ), button )
    end

    function self:getState()
        return stateManager:getState()
    end

    function self:getCurrentCharacter()
        return factions:getFaction():getCurrentCharacter();
    end

    return self;
end

return CombatState
