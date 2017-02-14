local Log = require( 'src.util.Log' );
local Object = require('src.Object');
local BehaviorTreeFactory = require( 'src.characters.ai.behaviortree.BehaviorTreeFactory' );

local SadisticAIDirector = {};

function SadisticAIDirector.new( factions, states )
    local self = Object.new():addInstance( 'SadisticAIDirector' );

    local tree = BehaviorTreeFactory.create();

    local function tickBehaviorTree( character )
        Log.debug( "Tick BehaviorTree for " .. tostring( character ), 'SadisticAIDirector' );
        return tree:traverse( {}, character, states, factions );
    end

    function self:update()
        local faction = factions:getFaction();
        if faction:hasFinishedTurn() then
            Log.debug( 'Select next faction', 'SadisticAIDirector' );
            factions:nextFaction();
            return;
        end

        -- Select the next character who hasn't finished his turn yet.
        Log.debug( 'Select next character for this turn', 'SadisticAIDirector' );
        local character = faction:nextCharacterForTurn();

        local success = tickBehaviorTree( character );
        if success then
            states:push( 'execution', factions, character );
            return;
        end

        -- Mark the character as done for this turn.
        character:setFinishedTurn( true );
    end

    return self;
end

return SadisticAIDirector;
