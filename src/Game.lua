local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );
local Map = require( 'src.map.Map' );
local Factions = require( 'src.characters.Factions' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local SaveHandler = require( 'src.SaveHandler' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Game = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );
local ITEM_TYPES = require('src.constants.ItemTypes');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Game.new()
    local self = Object.new():addInstance( 'Game' );

    local map;
    local factions;
    local turnManager;
    local observations = {};

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function spawnAmmo()
        map:iterate( function( tile, x, y )
            if tile:hasWorldObject() and tile:getWorldObject():isContainer() then
                local tries = love.math.random( 1, 5 );
                for _ = 1, tries do
                    if love.math.random( 100 ) < 25 then
                        local item = ItemFactory.createRandomItem( 'all', ITEM_TYPES.AMMO );
                        tile:getWorldObject():getInventory():addItem( item );
                        Log.debug( string.format( 'Spawned %s in container at %d, %d', item:getID(), x, y ), 'Game' );
                    end
                end
            end
        end);
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        map = Map.new();
        factions = Factions.new( map );
        factions:init();

        -- Load previously saved state or create new state.
        if SaveHandler.hasSaveFile() then
            local savegame = SaveHandler.load();
            savegame:loadMap( map );
            savegame:loadCharacters( map, factions );
        else
            map:init();
            spawnAmmo();
            factions:spawnCharacters();
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

return Game;
