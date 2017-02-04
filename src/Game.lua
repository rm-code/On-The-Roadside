local Object = require( 'src.Object' );
local Map = require( 'src.map.Map' );
local Factions = require( 'src.characters.Factions' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local BodyFactory = require( 'src.characters.body.BodyFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local SaveHandler = require( 'src.SaveHandler' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Game = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

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
                        local item = ItemFactory.createRandomItem( ITEM_TYPES.AMMO );
                        tile:getWorldObject():getInventory():addItem( item );
                        print( string.format( 'Spawned %s in container at %d, %d', item:getID(), x, y ));
                    end
                end
            end
        end);
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        BodyFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        SoundManager.loadResources();

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
    end

    function self:getMap()
        return map;
    end

    function self:getFactions()
        return factions;
    end

    function self:keypressed( key, scancode, isrepeat )
        turnManager:keypressed( key, scancode, isrepeat );
        if scancode == '.' then
            -- TODO Optimisation!
            -- SaveHandler.save( map:serialize() );
            collectgarbage( 'collect' );
        elseif scancode == '-' then
            -- SaveHandler.deleteSaveFile();
        end
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
