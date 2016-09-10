local BTComposite      = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence       = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTSelector       = require( 'src.characters.ai.behaviortree.composite.BTSelector' );
local BTReload         = require( 'src.characters.ai.behaviortree.leafs.BTReload' );
local BTAquireTarget   = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTAttackTarget   = require( 'src.characters.ai.behaviortree.leafs.BTAttackTarget' );
local BTCanAttack      = require( 'src.characters.ai.behaviortree.leafs.BTCanAttack' );
local BTCanReload      = require( 'src.characters.ai.behaviortree.leafs.BTCanReload' );
local BTMustReload     = require( 'src.characters.ai.behaviortree.leafs.BTMustReload' );
local BTHasRangedWeapon = require( 'src.characters.ai.behaviortree.leafs.BTHasRangedWeapon' );

local BehaviorTree = {};

function BehaviorTree.new()
    local self = BTComposite.new():addInstance( 'BehaviorTree' );

    local attackSequence = BTSequence.new();
    attackSequence:addNode( BTHasRangedWeapon.new() );
    attackSequence:addNode( BTAquireTarget.new() );
    attackSequence:addNode( BTCanAttack.new() );
    attackSequence:addNode( BTAttackTarget.new() );

    local reloadSequence = BTSequence.new();
    reloadSequence:addNode( BTHasRangedWeapon.new() );
    reloadSequence:addNode( BTMustReload.new() );
    reloadSequence:addNode( BTCanReload.new() );
    reloadSequence:addNode( BTReload.new() );

    local baseSelector = BTSelector.new();
    baseSelector:addNode( attackSequence );
    baseSelector:addNode( reloadSequence );

    self:addNode( baseSelector );

    return self;
end

return BehaviorTree;
