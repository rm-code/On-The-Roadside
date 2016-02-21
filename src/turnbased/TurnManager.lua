local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
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

    local function commitPath()
        character:getPath():iterate( function( tile )
            if tile:instanceOf( 'Door' ) and not tile:isPassable() then
                character:enqueueAction( OpenDoor.new( character, tile ));
            else
                character:enqueueAction( Walk.new( character ));
            end
        end)
    end

    local function generatePath( target )
        if target then
            local origin = character:getTile();
            local path = PathFinder.generatePath( origin, target, true );

            if path then
                character:addPath( path );
            else
                print( "Can't find path!");
            end
        end
    end

    local function checkMovement( target )
        if not character:hasPath() or target ~= character:getPath():getTarget() then
            generatePath( target );
        else
            commitPath();
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        if actionTimer > 0.40 and character:canPerformAction() then
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

    Messenger.observe( 'LEFT_CLICKED_TILE', function( tile )
        checkMovement( tile );
    end)

    Messenger.observe( 'RIGHT_CLICKED_TILE', function( tile )
        if tile:isOccupied() then
            character = CharacterManager.selectCharacter( tile );
        end
    end)

    return self;
end

return TurnManager;
