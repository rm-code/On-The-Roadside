local Object = require('src.Object');

local SadisticAIDirector = {};

function SadisticAIDirector.new( factions, states )
    local self = Object.new():addInstance( 'SadisticAIDirector' );

    local tiles = {};

    local startCharacter = factions:getFaction():getCurrentCharacter();
    local startFaction   = factions:getFaction();

    local function analyzeMap( character )
        for i, _ in pairs( tiles ) do
            tiles[i] = nil;
        end

        -- Get the character's FOV and store the tiles in a sequence for easier access.
        local fov = character:getFOV();
        for _, rx in pairs( fov ) do
            for _, target in pairs( rx ) do
                tiles[#tiles + 1] = target;
            end
        end

        -- Enter attack mode.
        states:keypressed( 'a' );

        -- Get all characters visible to this character.
        local enemies = {};
        for i = 1, #tiles do
            local tile = tiles[i];
            if tile:isOccupied() and tile:getCharacter():getFaction():getType() ~= character:getFaction():getType() then
                enemies[#enemies + 1] = tile;
            end
        end

        -- Select the closest enemy.
        local target;
        for i = 1, #enemies do
            local t = enemies[i];
            if not target then
                target = t;
            else
                local distanceX = math.abs( target:getX() - character:getTile():getX() );
                local distanceY = math.abs( target:getY() - character:getTile():getY() );

                local ndistanceX = math.abs( t:getX() - character:getTile():getX() );
                local ndistanceY = math.abs( t:getY() - character:getTile():getY() );

                if ndistanceX + ndistanceY < distanceX + distanceY then
                    target = t;
                end
            end
        end

        -- Attack the closest enemy.
        if target then
            states:selectTile( target, 1 );
            states:push( 'execution', character );
            return true;
        end

        -- Move around randomly.
        states:keypressed( 'm' ); -- Enter movement mode.
        local target = tiles[love.math.random( 1, #tiles )];
        if target:isPassable() and not target:isOccupied() then
            states:selectTile( target, 1 );
            states:push( 'execution', character );
            return true;
        end
    end

    function self:update()
        if factions:getFaction() ~= startFaction then
            startCharacter = factions:getFaction():getCurrentCharacter();
            startFaction   = factions:getFaction();
        end

        local character = factions:getFaction():getCurrentCharacter();

        if not analyzeMap( character ) or ( character:hasEnqueuedAction() and not character:canPerformAction() ) then
            local nextCharacter = factions:getFaction():nextCharacter();
            if nextCharacter == startCharacter then
                factions:nextFaction();
            end
        end
    end

    return self;
end

return SadisticAIDirector;
