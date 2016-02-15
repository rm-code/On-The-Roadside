local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local TurnManager = require( 'src.turnbased.TurnManager' );

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

    function self:init()
        map = Map.new();
        map:init();

        CharacterManager.newCharacter( map:getTileAt(  2,  2 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt(  2,  3 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt(  2,  4 ), FACTIONS.ALLIED  );
        CharacterManager.newCharacter( map:getTileAt(  2, 32 ), FACTIONS.NEUTRAL );
        CharacterManager.newCharacter( map:getTileAt( 47,  2 ), FACTIONS.ENEMY   );
        CharacterManager.newCharacter( map:getTileAt( 47,  3 ), FACTIONS.ENEMY   );
        CharacterManager.newCharacter( map:getTileAt( 47,  4 ), FACTIONS.ENEMY   );

        turnManager = TurnManager.new( map );
    end

    function self:update( dt )
        turnManager:update( dt )
    end

    function self:getMap()
        return map;
    end

    return self;
end

return Game;
