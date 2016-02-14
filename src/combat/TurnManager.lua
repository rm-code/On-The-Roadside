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

    local character = CharacterManager.getCurrentCharacter();
    local actionTimer = 0;

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

    function self:update( dt )
        if actionTimer > 0.15 and character:canPerformAction() then
            character:performAction();
            actionTimer = 0;
        end
        actionTimer = actionTimer + dt;
    end

    function self:keypressed( key )
        if key == 'space' then
            character = CharacterManager.nextCharacter();
        elseif key == 'return' then
            for _, char in ipairs( CharacterManager.getCharacters() ) do
                char:resetActionPoints();
                char:clearActions();
            end
            CharacterManager.nextFaction();
            character = CharacterManager.getCurrentCharacter();
        end
    end

    function self:mousepressed( mx, my, button )
        local tx, ty = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
        local tile = map:getTileAt( tx, ty );
        character:clearActions();

        if button == 1 then
            if tile:getWorldObject():instanceOf( 'Door' ) then
                setTarget( tile, false );
                if not tile:getWorldObject():isPassable() then
                    character:enqueueAction( OpenDoor.new( character, tile ));
                else
                    character:enqueueAction( CloseDoor.new( character, tile ));
                end
            else
                setTarget( tile, true );
            end
        elseif button == 2 then
            character = CharacterManager.selectCharacter( tile );
        end
    end

    return self;
end

return TurnManager;
