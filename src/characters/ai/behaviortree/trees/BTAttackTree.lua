local BTComposite      = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence       = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTSelector       = require( 'src.characters.ai.behaviortree.composite.BTSelector' );
local BTHasMeleeWeapon = require( 'src.characters.ai.behaviortree.leafs.BTHasMeleeWeapon' );
local BTReload         = require( 'src.characters.ai.behaviortree.leafs.BTReload' );
local BTAquireTarget   = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTAttackTarget   = require( 'src.characters.ai.behaviortree.leafs.BTAttackTarget' );
local BTCanAttack      = require( 'src.characters.ai.behaviortree.leafs.BTCanAttack' );
local BTCanReload      = require( 'src.characters.ai.behaviortree.leafs.BTCanReload' );
local BTMustReload     = require( 'src.characters.ai.behaviortree.leafs.BTMustReload' );
local BTInverter       = require( 'src.characters.ai.behaviortree.decorators.BTInverter' );

local BehaviorTree = {};

function BehaviorTree.new()
    local self = BTComposite.new():addInstance( 'BehaviorTree ');

    local inverter = BTInverter.new();
    inverter:addNode( BTHasMeleeWeapon.new() );

    local attackSequence = BTSequence.new();
    attackSequence:addNode( inverter );
    attackSequence:addNode( BTCanAttack.new() );
    attackSequence:addNode( BTAquireTarget.new() );
    attackSequence:addNode( BTAttackTarget.new() );

    local reloadSequence = BTSequence.new();
    reloadSequence:addNode( inverter );
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
