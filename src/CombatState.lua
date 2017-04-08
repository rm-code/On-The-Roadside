---
-- @module CombatState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' );
local MapLoader = require( 'src.map.MapLoader' )
local Factions = require( 'src.characters.Factions' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

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
    local turnManager;
    local observations = {};

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

        turnManager = TurnManager.new( map, factions );

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
        turnManager:update( dt )

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
        turnManager:keypressed( key, scancode, isrepeat );
    end

    function self:mousepressed( mx, my, button )
        turnManager:mousepressed( mx, my, button );
    end

    function self:getState()
        return turnManager:getState();
    end

    function self:getCurrentCharacter()
        return factions:getFaction():getCurrentCharacter();
    end

    return self;
end

return CombatState