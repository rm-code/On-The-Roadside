local Attack = require( 'src.characters.actions.Attack' );
local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Bresenham = require( 'lib.Bresenham' );
local LineOfSight = require( 'src.characters.LineOfSight' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TURN_STEP_DELAY = 0.15;
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local character = CharacterManager.getCurrentCharacter();
    local actionTimer = 0;
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
            if tile:hasWorldObject() and tile:getWorldObject():getType() == 'worldobject_door' and not tile:isPassable() then
                character:enqueueAction( OpenDoor.new( character, tile ));
                -- Don't walk on the door tile if the path ends there.
                if index ~= 1 then
                    character:enqueueAction( Walk.new( character, tile ));
                end
            else
                character:enqueueAction( Walk.new( character, tile ));
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

    local function generateAttack( target )
        character:enqueueAction( Attack.new( character, target, map ));
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
            end
            CharacterManager.removeDeadActors();
        end
        actionTimer = actionTimer + dt;
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    function self:keypressed( key )
        if key == 'a' then
            attackMode = true;
        elseif key == 'escape' then
            attackMode = false;
        end

        if key == 'space' then
            attackMode = false;
            character = CharacterManager.nextCharacter();
        elseif key == 'return' then
            attackMode = false;
            CharacterManager.clearCharacters();
            CharacterManager.nextFaction();
            character = CharacterManager.getCurrentCharacter();
        end

        if key == 'right' then
            character:getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            character:getWeapon():selectPrevFiringMode();
        end
    end

    function self:mousepressed( mx, my, button )
        local tile = map:getTileAt( math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE ));
        if button == 1 then
            if attackMode then
                checkAttack( tile );
            else
                checkMovement( tile );
            end
        elseif button == 2 then
            if tile:isOccupied() then
                character = CharacterManager.selectCharacter( tile );
            elseif tile:hasWorldObject() and tile:getWorldObject():getType() == 'worldobject_door' and tile:isAdjacent( character:getTile() ) then
                if tile:isPassable() then
                    character:enqueueAction( CloseDoor.new( character, tile ));
                else
                    character:enqueueAction( OpenDoor.new( character, tile ));
                end
            end
        end
    end

    return self;
end

return TurnManager;
