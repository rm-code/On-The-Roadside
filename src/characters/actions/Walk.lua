local Object = require('src.Object');

local Walk = {};

function Walk.new( character, targetTile )
    local self = Object.new():addInstance( 'Walk' );

    function self:perform()
        local currentTile = character:getTile();

        if targetTile:getWorldObject():isPassable() and not targetTile:isOccupied() then
            -- Remove the character from the old tile, add it to the new one and
            -- give it a reference to the new tile.
            currentTile:removeCharacter();
            targetTile:setCharacter( character );
            character:setTile( targetTile );
        end
    end

    return self;
end

return Walk;
