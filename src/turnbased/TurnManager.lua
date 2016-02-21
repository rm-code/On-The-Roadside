local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );
local PathFinder = require( 'src.turnbased.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new()
    local self = {};

    local character = CharacterManager.getCurrentCharacter();
    local actionTimer = 0;

    -- ------------------------------------------------
    -- Local Methods
    -- ------------------------------------------------

    local function setTarget( target, adjacent )
        if target then
            local origin = character:getTile();
            local path = PathFinder.generatePath( origin, target, adjacent );

            if path then
                character:addPath( path );
                for _ = 1, path:getLength() do
                    character:enqueueAction( Walk.new( character ));
                end
            else
                print( "Can't find path!");
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        if actionTimer > 0.15 and character:canPerformAction() then
            character:performAction();
            actionTimer = 0;
        end
        actionTimer = actionTimer + dt;
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    Messenger.observe( 'SWITCH_CHARACTERS', function()
        character = CharacterManager.nextCharacter();
    end)

    Messenger.observe( 'SWITCH_FACTION', function()
        for _, char in ipairs( CharacterManager.getCharacters() ) do
            char:resetActionPoints();
            char:clearActions();
        end
        CharacterManager.nextFaction();
        character = CharacterManager.getCurrentCharacter();
    end)

    Messenger.observe( 'CLICKED_CLOSED_DOOR', function( tile )
        setTarget( tile, false );
        character:enqueueAction( OpenDoor.new( character, tile ));
    end)

    Messenger.observe( 'CLICKED_OPEN_DOOR', function( tile )
        setTarget( tile, false );
        character:enqueueAction( CloseDoor.new( character, tile ));
    end)

    Messenger.observe( 'CLICKED_TILE', function( tile )
        setTarget( tile, true );
    end)

    Messenger.observe( 'RIGHT_CLICKED_CHARACTER', function( tile )
        character = CharacterManager.selectCharacter( tile );
    end)

    return self;
end

return TurnManager;
