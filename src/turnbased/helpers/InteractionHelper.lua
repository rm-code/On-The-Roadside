local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );

local InteractionHelper = {};

function InteractionHelper.request( map, tile, character, states )
    if tile:hasWorldObject() and tile:getWorldObject():isOpenable() and tile:isAdjacent( character:getTile() ) then
        if tile:isPassable() then
            character:enqueueAction( Close.new( character, tile ));
        else
            character:enqueueAction( Open.new( character, tile ));
        end
        states:push( 'execution' );
    end
end

function InteractionHelper.getType()
    return 'interact';
end

return InteractionHelper;
