local Action = require( 'src.characters.actions.Action' );

local ClimbOver = {};

function ClimbOver.new( character, target )
    local self = Action.new( target:getWorldObject():getInteractionCost(), target ):addInstance( 'ClimbOver' );

    ---
    -- Gets the direction of the target tile in relation to the character's
    -- current location.
    -- @param neighbours (table)  A table containing all the neighbouring tiles.
    -- @return           (string) The direction of the tile.
    --
    local function findDirection( neighbours )
        for dir, neighbour in pairs( neighbours ) do
            if neighbour == target then
                return dir;
            end
        end
    end

    ---
    -- Checks if the tile behind the WorldObject is free to move to.
    -- @param toCheck (Tile)    The tile to check.
    -- @return        (boolean) True if it is a valid tile.
    --
    local function isValidTarget( toCheck )
        return toCheck:isPassable() and not toCheck:isOccupied() and not toCheck:hasWorldObject();
    end

    function self:perform()
        local current = character:getTile();

        assert( target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' );

        local direction = findDirection( current:getNeighbours() );
        local tileBehindObject = target:getNeighbours()[direction];

        if isValidTarget( tileBehindObject ) then
            current:removeCharacter();
            target:addCharacter( character );
            character:setTile( target );
        end
    end

    return self;
end

return ClimbOver;
