local BTComposite      = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence       = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTSelector       = require( 'src.characters.ai.behaviortree.composite.BTSelector' );
local BTAttackTree     = require( 'src.characters.ai.behaviortree.trees.BTAttackTree' );
local BTRandomMovement = require( 'src.characters.ai.behaviortree.leafs.BTRandomMovement' );

local BehaviorTree = {};

function BehaviorTree.new()
    local self = BTComposite.new():addInstance( 'BehaviorTree ');

    local moveSequence = BTSequence.new();
    moveSequence:addNode( BTRandomMovement.new() );

    local baseSelector = BTSelector.new();
    baseSelector:addNode( BTAttackTree.new() );
    baseSelector:addNode( moveSequence );

    self:addNode( baseSelector );

    return self;
end

return BehaviorTree;
