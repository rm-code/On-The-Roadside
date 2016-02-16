local Object = require('src.Object');

local Walk = {};

function Walk.new( character )
    local self = Object.new():addInstance( 'Walk' );

    function self:perform()
        local currentTile = character:getTile();
        local targetTile = character:getPath():getNextNode();

        if targetTile:getWorldObject():isPassable() and not targetTile:isOccupied() then
            -- Remove the character from the old tile, add it to the new one and
            -- give it a reference to the new tile.
            currentTile:removeCharacter();
            targetTile:addCharacter( character );
            character:setTile( targetTile );
        end
    end

    function self:getCost()
        return 1;
    end

    return self;
end

return Walk;
