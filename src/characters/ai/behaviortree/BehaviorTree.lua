local BTComposite      = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence       = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTSelector       = require( 'src.characters.ai.behaviortree.composite.BTSelector' );
local BTRangedTree     = require( 'src.characters.ai.behaviortree.trees.BTRangedTree' );
local BTMeleeTree      = require( 'src.characters.ai.behaviortree.trees.BTMeleeTree' );
local BTGrenadeTree    = require( 'src.characters.ai.behaviortree.trees.BTGrenadeTree' );
local BTRandomMovement = require( 'src.characters.ai.behaviortree.leafs.BTRandomMovement' );
local BTHasWeapon      = require( 'src.characters.ai.behaviortree.leafs.BTHasWeapon' );

local BehaviorTree = {};

function BehaviorTree.new()
    local self = BTComposite.new():addInstance( 'BehaviorTree ');

    local moveSequence = BTSequence.new();
    moveSequence:addNode( BTRandomMovement.new() );

    local attackSelector = BTSelector.new();
    attackSelector:addNode( BTMeleeTree.new() );
    attackSelector:addNode( BTGrenadeTree.new() );
    attackSelector:addNode( BTRangedTree.new() );

    local attackSequence = BTSequence.new();
    attackSequence:addNode( BTHasWeapon.new() );
    attackSequence:addNode( attackSelector );

    local baseSelector = BTSelector.new();
    baseSelector:addNode( attackSequence );
    baseSelector:addNode( moveSequence );

    self:addNode( baseSelector );

    return self;
end

return BehaviorTree;
