local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );
local PathFinder = require( 'src.turnbased.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TURN_STEP_DELAY = 0.15;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new()
    local self = {};

    local character = CharacterManager.getCurrentCharacter();
    local actionTimer = 0;
    local blockInput = false;

    -- ------------------------------------------------
    -- Local Methods
    -- ------------------------------------------------

    local function commitPath()
        character:getPath():iterate( function( tile )
            if tile:instanceOf( 'Door' ) and not tile:isPassable() then
                character:enqueueAction( OpenDoor.new( character, tile ));
                character:enqueueAction( Walk.new( character, tile ));
            else
                character:enqueueAction( Walk.new( character, tile ));
            end
        end)
        blockInput = true;
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
        if not character:hasPath() then
            generatePath( target );
        elseif target ~= character:getPath():getTarget() then
            character:clearActions();
            character:removePath();
            generatePath( target );
        else
            commitPath();
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        if actionTimer > TURN_STEP_DELAY then
            if character:canPerformAction() then
                character:performAction();
                actionTimer = 0;
            else
                blockInput = false;
            end
        end
        actionTimer = actionTimer + dt;
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    Messenger.observe( 'SWITCH_CHARACTERS', function()
        if not blockInput then
            character = CharacterManager.nextCharacter();
        end
    end)

    Messenger.observe( 'SWITCH_FACTION', function()
        if not blockInput then
            for _, char in ipairs( CharacterManager.getCharacters() ) do
                char:resetActionPoints();
                char:clearActions();
                char:removePath();
            end
            CharacterManager.nextFaction();
            character = CharacterManager.getCurrentCharacter();
        end
    end)

    Messenger.observe( 'LEFT_CLICKED_TILE', function( tile )
        if not blockInput then
            checkMovement( tile );
        end
    end)

    Messenger.observe( 'RIGHT_CLICKED_TILE', function( tile )
        if not blockInput then
            if tile:isOccupied() then
                character = CharacterManager.selectCharacter( tile );
            elseif tile:instanceOf( 'Door' ) and tile:isAdjacent( character:getTile() ) then
                if tile:isPassable() then
                    character:enqueueAction( CloseDoor.new( character, tile ));
                else
                    character:enqueueAction( OpenDoor.new( character, tile ));
                end
            end
        end
    end)

    return self;
end

return TurnManager;
