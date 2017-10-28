---
-- @module CombatState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' );
local MapGenerator = require( 'src.map.procedural.MapGenerator' )
local ProceduralMap = require( 'src.map.procedural.ProceduralMap' )
local Factions = require( 'src.characters.Factions' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local StateManager = require( 'src.turnbased.states.StateManager' )
local SadisticAIDirector = require( 'src.characters.ai.SadisticAIDirector' )
local Faction = require( 'src.characters.Faction' )

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

    function self:init( playerFaction, savegame )
        local generator = MapGenerator.new()
        generator:init()

        local tiles = generator:getTiles()
        local mw, mh = generator:getTileGridDimensions()

        map = ProceduralMap.new( tiles, mw, mh )
        map:init()
        map:setSpawnpoints( generator:getSpawnpoints() )

        factions = Factions.new( map );
        factions:addFaction( Faction.new( FACTIONS.ENEMY,   true ))
        factions:addFaction( Faction.new( FACTIONS.NEUTRAL, true ))
        factions:addFaction( playerFaction )

        if savegame then
            factions:findFaction( FACTIONS.ENEMY   ):loadCharacters( savegame.factions[FACTIONS.ENEMY] )
            factions:findFaction( FACTIONS.NEUTRAL ):loadCharacters( savegame.factions[FACTIONS.NEUTRAL] )
        else
            factions:findFaction( FACTIONS.ENEMY   ):addCharacters( 10, 'human' )
            factions:findFaction( FACTIONS.NEUTRAL ):addCharacters(  5, 'dog'   )
        end

        factions:findFaction( FACTIONS.ENEMY   ):spawnCharacters( map )
        factions:findFaction( FACTIONS.NEUTRAL ):spawnCharacters( map )
        playerFaction:spawnCharacters( map )

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
        observations[#observations + 1] = map:observe( factions )

        -- Free memory if possible.
        collectgarbage( 'collect' );
    end

    function self:update( dt )
        map:update();

        -- Update AI if current faction is AI controlled.
        if factions:getFaction():isAIControlled() and not stateManager:blocksInput() then
            sadisticAIDirector:update( dt )
        end
        stateManager:update( dt )

        if not factions:findFaction( FACTIONS.ALLIED ):hasLivingCharacters() then
            ScreenManager.pop()
            ScreenManager.push( 'gameover', factions:getPlayerFaction(), false )
        end
        if not factions:findFaction( FACTIONS.ENEMY ):hasLivingCharacters() then
            ScreenManager.pop()
            ScreenManager.push( 'gameover', factions:getPlayerFaction(), true )
        end
    end

    function self:serialize()
        local t = {
            ['type'] = 'combat',
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
