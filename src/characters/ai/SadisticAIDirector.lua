local Object = require('src.Object');
local FactionManager = require( 'src.characters.FactionManager' );

local SadisticAIDirector = {};

function SadisticAIDirector.new( map, states )
    local self = Object.new():addInstance( 'SadisticAIDirector' );

    local tiles = {};

    local startCharacter = FactionManager.getCurrentCharacter();
    local startFaction   = FactionManager.getFaction();

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

        -- Shoot at an enemy character if one is visible.
        states:keypressed( 'a' );
        for i = 1, #tiles do
            local tile = tiles[i];
            if tile:isOccupied() and tile:getCharacter():getFaction():getType() ~= character:getFaction():getType() then
                states:selectTile( tile, 1 );
                states:push( 'execution' );
                return true;
            end
        end

        -- Move around randomly.
        states:keypressed( 'm' ); -- Enter movement mode.
        local target = tiles[love.math.random( 1, #tiles )];
        if target:isPassable() and not target:isOccupied() then
            states:selectTile( target, 1 );
            states:push( 'execution' );
            return true;
        end
    end

    function self:update()
        if FactionManager.getFaction() ~= startFaction then
            startCharacter = FactionManager.getCurrentCharacter();
            startFaction   = FactionManager.getFaction();
        end

        local character = FactionManager.getCurrentCharacter();

        if not analyzeMap( character ) or ( character:hasEnqueuedAction() and not character:canPerformAction() ) then
            local nextCharacter = FactionManager.nextCharacter();
            if nextCharacter == startCharacter then
                FactionManager.nextFaction();
            end
        end
    end

    return self;
end

return SadisticAIDirector;
