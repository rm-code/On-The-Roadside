local Attack = require( 'src.characters.actions.Attack' );
local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Messenger = require( 'src.Messenger' );
local Bresenham = require( 'lib.Bresenham' );
local LineOfSight = require( 'src.turnbased.LineOfSight' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TURN_STEP_DELAY = 0.15;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local character = CharacterManager.getCurrentCharacter();
    local actionTimer = 0;
    local blockInput = false;
    local attackMode = false;

    -- ------------------------------------------------
    -- Local Methods
    -- ------------------------------------------------

    local function generateLineOfSight( target )
        local ox, oy = character:getTile():getPosition();
        local tx, ty = target:getPosition();

        local seenTiles = {};

        Bresenham.calculateLine( ox, oy, tx, ty, function( sx, sy )
            seenTiles[#seenTiles + 1] = map:getTileAt( sx, sy );
            return true;
        end)

        character:addLineOfSight( LineOfSight.new( seenTiles ));
    end

    local function commitPath()
        character:getPath():iterate( function( tile, index )
            if tile:instanceOf( 'Door' ) and not tile:isPassable() then
                character:enqueueAction( OpenDoor.new( character, tile ));
                -- Don't walk on the door tile if the path ends there.
                if index ~= 1 then
                    character:enqueueAction( Walk.new( character, tile ));
                end
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

    local function generateAttack( target )
        character:enqueueAction( Attack.new( character, target ));
    end

    local function checkMovement( target )
        if not character:hasPath() then
            generatePath( target );
            character:removeLineOfSight();
        elseif target ~= character:getPath():getTarget() then
            character:clearActions();
            character:removePath();
            character:removeLineOfSight();
            generatePath( target );
        else
            commitPath();
        end
    end

    local function checkAttack( target )
        if not character:hasLineOfSight() then
            generateLineOfSight( target );
        elseif target ~= character:getLineOfSight():getTarget() then
            character:clearActions();
            character:removePath();
            character:removeLineOfSight();
            generateLineOfSight( target );
        else
            generateAttack( target );
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
            CharacterManager.removeDeadActors();
        end
        actionTimer = actionTimer + dt;
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    Messenger.observe( 'ENTER_ATTACK_MODE', function()
        if not blockInput then
            attackMode = true;
        end
    end)

    Messenger.observe( 'ENTER_MOVEMENT_MODE', function()
        if not blockInput then
            attackMode = false;
        end
    end)

    Messenger.observe( 'SWITCH_CHARACTERS', function()
        if not blockInput then
            character = CharacterManager.nextCharacter();
        end
    end)

    Messenger.observe( 'SWITCH_FACTION', function()
        if not blockInput then
            CharacterManager.clearCharacters();
            CharacterManager.nextFaction();
            character = CharacterManager.getCurrentCharacter();
        end
    end)

    Messenger.observe( 'LEFT_CLICKED_TILE', function( tile )
        if not blockInput then
            if attackMode then
                checkAttack( tile );
            else
                checkMovement( tile );
            end
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
