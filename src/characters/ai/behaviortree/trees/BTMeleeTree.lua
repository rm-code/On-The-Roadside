local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTSelector = require( 'src.characters.ai.behaviortree.composite.BTSelector' );
local BTHasMeleeWeapon = require( 'src.characters.ai.behaviortree.leafs.BTHasMeleeWeapon' );
local BTAquireTarget = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTIsAdjacentToTarget = require( 'src.characters.ai.behaviortree.leafs.BTIsAdjacentToTarget' );
local BTMeleeAttack = require( 'src.characters.ai.behaviortree.leafs.BTMeleeAttack' );
local BTMoveToTarget = require( 'src.characters.ai.behaviortree.leafs.BTMoveToTarget' );

local BTMeleeTree = {};

function BTMeleeTree.new()
    local self = BTComposite.new():addInstance( 'BTMeleeTree');

    local baseSequence = BTSequence.new();
    baseSequence:addNode( BTHasMeleeWeapon.new() );

    local attackSequence = BTSequence.new();
    attackSequence:addNode( BTAquireTarget.new() );
    attackSequence:addNode( BTIsAdjacentToTarget.new() );
    attackSequence:addNode( BTMeleeAttack.new() );

    local moveSequence = BTSequence.new();
    moveSequence:addNode( BTAquireTarget.new() );
    moveSequence:addNode( BTMoveToTarget.new() );

    local selector = BTSelector.new();
    selector:addNode( attackSequence );
    selector:addNode( moveSequence );

    baseSequence:addNode( selector );

    self:addNode( baseSequence );

    return self;
end

return BTMeleeTree;
