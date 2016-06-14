local State = require( 'src.turnbased.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local OpenDoor = require( 'src.characters.actions.OpenDoor' );
local CloseDoor = require( 'src.characters.actions.CloseDoor' );

local InteractionState = {};

function InteractionState.new( stateManager )
    local self = State.new();

    local map;

    local function checkInteraction( tile, character )
        if tile:hasWorldObject() and tile:getWorldObject():getType() == 'worldobject_door' and tile:isAdjacent( character:getTile() ) then
            if tile:isPassable() then
                character:enqueueAction( CloseDoor.new( character, tile ));
            else
                character:enqueueAction( OpenDoor.new( character, tile ));
            end
            stateManager:switch( 'execution', { map = map } );
        end
    end

    function self:enter( params )
        map = params.map;
    end

    function self:keypressed( key )
        if key == 'escape' then
            stateManager:switch( 'movement', { map = map } );
        elseif key == 'space' then
            CharacterManager.nextCharacter();
        end
    end

    function self:mousepressed( mx, my, _ )
        local tile = map:getTileAt( mx, my );
        if not tile then
            return;
        end
        checkInteraction( tile, CharacterManager.getCurrentCharacter() );
    end

    return self;
end

return InteractionState;
