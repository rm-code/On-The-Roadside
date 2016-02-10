local Queue = require('src.combat.Queue');
local Walk = require( 'src.characters.actions.Walk' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );
local PathFinder = require( 'src.combat.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local actionQueue = Queue.new();
    local actionTimer = 0;

    local function setTarget( target )
        if target then
            local character = CharacterManager.getCurrentCharacter();
            local origin = character:getTile();
            local path = PathFinder.generatePath( origin, target );

            if path then
                for i = 1, #path do
                    actionQueue:enqueue( Walk.new( character, path[i] ));
                end
            else
                print( "Can't find path!");
            end
        end
    end

    function self:update( dt )
        if actionQueue:getSize() > 0 and actionTimer > 0.15 then
            local action = actionQueue:dequeue();
            action:perform();
            actionTimer = 0;
        end
        actionTimer = actionTimer + dt;
    end

    function self:keypressed( key )
        if key == 'space' then
            actionQueue:clear();
            CharacterManager.nextCharacter();
        end
    end

    function self:mousepressed( mx, my, button )
        local tx, ty = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
        if button == 1 then
            local tile = map:getTileAt( tx, ty )
            if tile:getWorldObject():instanceOf( 'Door' ) then
                setTarget( map:getTileAt( tx, ty ));
                if not tile:getWorldObject():isPassable() then
                    actionQueue:enqueue( OpenDoor.new( CharacterManager.getCurrentCharacter(), tile ));
                else
                    actionQueue:enqueue( CloseDoor.new( CharacterManager.getCurrentCharacter(), tile ));
                end
            else
                actionQueue:clear();
                setTarget( map:getTileAt( tx, ty ));
            end
        elseif button == 2 then
            actionQueue:clear();
            CharacterManager.selectCharacter( map:getTileAt( tx, ty ));
        end
    end

    return self;
end

return TurnManager;
