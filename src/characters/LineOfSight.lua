local Object = require('src.Object');

local LineOfSight = {};

function LineOfSight.new( tiles )
    local self = Object.new():addInstance( 'LineOfSight' );

    ---
    -- Iterates over the line of sight.
    -- @param callback (function) A function to call on every tile. If the
    --                             callback returns true the iteration will be
    --                             cancelled.
    --
    function self:iterate( callback )
        for i = 1, #tiles do
            if callback( tiles[i], i ) then
                return;
            end
        end
    end

    function self:getTarget()
        return tiles[#tiles];
    end

    return self;
end

return LineOfSight;
