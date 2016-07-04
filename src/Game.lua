local Map = require( 'src.map.Map' );
local FactionManager = require( 'src.characters.FactionManager' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Game = {};

function Game.new()
    local self = {};

    local map;
    local turnManager;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    -- TODO update visibility only when it is really necessary.
    local function updateVisibility()
        FactionManager.getFaction():generateFOV( map );
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
        FactionManager.newCharacter( map:getTileAt(  4,  4 ), FACTIONS.ALLIED  );
        FactionManager.newCharacter( map:getTileAt(  6, 17 ), FACTIONS.ALLIED  );
        FactionManager.newCharacter( map:getTileAt( 14,  8 ), FACTIONS.ALLIED  );
        FactionManager.newCharacter( map:getTileAt(  2, 33 ), FACTIONS.NEUTRAL );
        FactionManager.newCharacter( map:getTileAt( 47,  2 ), FACTIONS.ENEMY   );
        FactionManager.newCharacter( map:getTileAt( 47,  3 ), FACTIONS.ENEMY   );
        FactionManager.newCharacter( map:getTileAt( 47,  4 ), FACTIONS.ENEMY   );

        turnManager = TurnManager.new( map );

        ProjectileManager.init( map );
    end

    function self:update( dt )
        map:update();
        updateVisibility();
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

    return self;
end

return Game;
