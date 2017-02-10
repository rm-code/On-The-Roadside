local Log = require( 'src.util.Log' );
local Object = require('src.Object');
local BehaviorTree = require( 'src.characters.ai.behaviortree.BehaviorTree' );

local SadisticAIDirector = {};

function SadisticAIDirector.new( factions, states )
    local self = Object.new():addInstance( 'SadisticAIDirector' );

    local startCharacter = factions:getFaction():getCurrentCharacter();
    local startFaction   = factions:getFaction();

    local tree = BehaviorTree.new();

    local function tickBehaviorTree( character )
        Log.debug( "Tick BehaviorTree for " .. tostring( character ), 'SadisticAIDirector' );
        return tree:traverse( {}, character, states, factions );
    end

    function self:update()
        if factions:getFaction() ~= startFaction then
            startCharacter = factions:getFaction():getCurrentCharacter();
            startFaction   = factions:getFaction();
        end

        local character = factions:getFaction():getCurrentCharacter();

        if not tickBehaviorTree( character ) then
            local nextCharacter = factions:getFaction():nextCharacter();
            if nextCharacter == startCharacter then
                factions:nextFaction();
            end
        end
    end

    return self;
end

return SadisticAIDirector;
