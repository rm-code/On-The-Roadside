local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );

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
    local projectileManager;

    function self:init()
        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        SoundManager.loadResources();

        map = Map.new();
        map:init();

        CharacterManager.newCharacter( map:getTileAt(  4,  4 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt(  6, 17 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt( 14,  8 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt(  2, 33 ), FACTIONS.NEUTRAL );
        CharacterManager.newCharacter( map:getTileAt( 47,  2 ), FACTIONS.ENEMY   );
        CharacterManager.newCharacter( map:getTileAt( 47,  3 ), FACTIONS.ENEMY   );
        CharacterManager.newCharacter( map:getTileAt( 47,  4 ), FACTIONS.ENEMY   );

        turnManager = TurnManager.new( map );

        projectileManager = ProjectileManager.new( map );
    end

    function self:update( dt )
        turnManager:update( dt )
        projectileManager:update( dt );
    end

    function self:getMap()
        return map;
    end

    function self:getProjectiles()
        return projectileManager;
    end

    function self:getActiveCharacter()
        return CharacterManager.getCurrentCharacter();
    end

    return self;
end

return Game;
