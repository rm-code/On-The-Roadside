local State = require( 'src.turnbased.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

local MovementState = {};

function MovementState.new( stateManager )
    local self = State.new();

    local map;

    function self:enter( params )
        map = params.map;
    end

    local function commitPath( character )
        character:getPath():iterate( function( tile, index )
            if tile:hasWorldObject() and tile:getWorldObject():getType() == 'worldobject_door' and not tile:isPassable() then
                character:enqueueAction( OpenDoor.new( character, tile ));
                -- Don't walk on the door tile if the path ends there.
                if index ~= 1 then
                    character:enqueueAction( Walk.new( character, tile ));
                end
            elseif tile:hasWorldObject() and tile:getWorldObject():getType() == 'worldobject_fence' then
                character:enqueueAction( ClimbOver.new( character, tile ));
            else
                character:enqueueAction( Walk.new( character, tile ));
            end
        end)
        stateManager:switch( 'execution', { map = map } );
    end

    local function generatePath( target, character )
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

    local function checkMovement( target, character )
        if not character:hasPath() then
            generatePath( target, character );
            character:removeLineOfSight();
        elseif target ~= character:getPath():getTarget() then
            character:clearActions();
            character:removePath();
            character:removeLineOfSight();
            generatePath( target, character );
        else
            commitPath( character, character );
        end
    end

    function self:keypressed( key )
        if key == 'a' then
            stateManager:switch( 'attack', { map = map } );
        elseif key == 'e' then
            stateManager:switch( 'interact', { map = map } );
        elseif key == 'space' then
            CharacterManager.nextCharacter();
        end

        -- TODO: remove
        if key == 'return' then
            CharacterManager.clearCharacters();
            CharacterManager.nextFaction();
        end
    end

    function self:mousepressed( mx, my, _ )
        local tile = map:getTileAt( mx, my );
        if not tile then
            return;
        end
        checkMovement( tile, CharacterManager.getCurrentCharacter() );
    end

    return self;
end

return MovementState;
