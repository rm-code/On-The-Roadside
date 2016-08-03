local Object = require( 'src.Object' );
local Map = require( 'src.map.Map' );
local FactionManager = require( 'src.characters.FactionManager' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Game = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Game.new()
    local self = Object.new():addInstance( 'Game' );

    local map;
    local turnManager;
    local observations = {};

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Spawns characters on the map.
    --
    local function spawnCharacters( amount, faction )
        for _ = 1, amount do
            FactionManager.newCharacter( map, map:findSpawnPoint( faction ), faction );
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        SoundManager.loadResources();

        map = Map.new();
        map:init();

        FactionManager.init();

        spawnCharacters( 10, FACTIONS.ALLIED  );
        spawnCharacters(  5, FACTIONS.NEUTRAL );
        spawnCharacters( 10, FACTIONS.ENEMY   );

        turnManager = TurnManager.new( map );

        ProjectileManager.init( map );
        ExplosionManager.init( map );

        -- Register obsersvations.
        observations[#observations + 1] = map:observe( self );
    end

    function self:receive( event, ... )
        if event == 'TILE_UPDATED' then
            local tile = ...;
            assert( tile:instanceOf( 'Tile' ), 'Expected an object of type Tile.' );
            FactionManager.getFaction():regenerateFOVSelectively( tile );
        end
    end

    function self:update( dt )
        map:update();
        turnManager:update( dt )
    end

    function self:getMap()
        return map;
    end

    function self:keypressed( key )
        turnManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        turnManager:mousepressed( mx, my, button );
    end

    function self:getState()
        return turnManager:getState();
    end

    function self:getCurrentCharacter()
        return FactionManager.getCurrentCharacter();
    end

    return self;
end

return Game;
