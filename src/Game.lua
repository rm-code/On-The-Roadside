local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local TurnManager = require( 'src.combat.TurnManager' );

local Game = {};

function Game.new()
    local self = {};

    local map;
    local turnManager;

    function self:init()
        map = Map.new();
        map:init();

        CharacterManager.newCharacter( map:getTileAt( 2, 2 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 3 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 4 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 5 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 6 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 7 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 8 ));

        turnManager = TurnManager.new( map );
    end

    function self:update( dt )
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
