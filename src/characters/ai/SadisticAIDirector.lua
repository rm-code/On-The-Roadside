---
-- @module SadisticAIDirector
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local BehaviorTreeFactory = require( 'src.characters.ai.behaviortree.BehaviorTreeFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SadisticAIDirector = Class( 'SadisticAIDirector' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function tickBehaviorTree( tree, character, states, factions )
    Log.debug( "Tick BehaviorTree for " .. tostring( character ), 'SadisticAIDirector' )
    return tree:traverse( {}, character, states, factions )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function SadisticAIDirector:initialize( factions, states )
    self.factions = factions
    self.states = states
end

function SadisticAIDirector:update()
    local faction = self.factions:getFaction()
    local tree = BehaviorTreeFactory.getTree( faction:getType() )
    if faction:hasFinishedTurn() then
        Log.debug( 'Select next faction', 'SadisticAIDirector' )
        self.factions:nextFaction()
        return
    end

    -- Select the next character who hasn't finished his turn yet.
    Log.debug( 'Select next character for this turn', 'SadisticAIDirector' )
    local character = faction:nextCharacterForTurn()

    local success = tickBehaviorTree( tree, character, self.states, self.factions )
    if success then
        self.states:push( 'execution', self.factions, character )
        return
    end

    -- Mark the character as done for this turn.
    character:setFinishedTurn( true )
end

return SadisticAIDirector
