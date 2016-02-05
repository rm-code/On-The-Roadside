local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local TurnManager = require( 'src.combat.TurnManager' );
local WorldPainter = require( 'src.ui.WorldPainter' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local map;
    local turnManager;
    local worldPainter;

    ---
    -- Updates the field of view on the map.
    --
    local function updateFOV()
        map:resetVisibility();
        for _, char in ipairs( CharacterManager.getCharacters() ) do
            map:calculateVisibility( char:getTile() );
        end
    end

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

        worldPainter = WorldPainter.new( map );
        worldPainter.init();
    end

    function self:draw()
        worldPainter.draw();
    end

    function self:update( dt )
        worldPainter.update( dt );
        updateFOV();
        turnManager:update( dt )
    end

    function self:keypressed( key )
        turnManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        turnManager:mousepressed( mx, my, button );
    end

    return self;
end

return MainScreen;
