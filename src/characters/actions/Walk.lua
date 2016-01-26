local Object = require('src.Object');

local Walk = {};

function Walk.new( character, target )
    local self = Object.new():addInstance( 'Walk' );

    function self:perform()
        -- Remove the character from the old tile, add it to the new one and
        -- give it a reference to the new tile.
        character:getTile():removeCharacter();
        target:setCharacter( character );
        character:setTile( target );
    end

    return self;
end

return Walk;
