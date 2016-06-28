local State = require( 'src.turnbased.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );

local InteractionState = {};

function InteractionState.new( stateManager )
    local self = State.new();

    local map;

    local function checkInteraction( tile, character )
        if tile:hasWorldObject() and tile:getWorldObject():isOpenable() and tile:isAdjacent( character:getTile() ) then
            if tile:isPassable() then
                character:enqueueAction( Close.new( character, tile ));
            else
                character:enqueueAction( Open.new( character, tile ));
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
