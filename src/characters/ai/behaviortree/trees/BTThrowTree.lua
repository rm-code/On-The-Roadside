local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTHasThrowingWeapon = require( 'src.characters.ai.behaviortree.leafs.BTHasThrowingWeapon' );
local BTAquireTarget = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTThrowingAttack = require( 'src.characters.ai.behaviortree.leafs.BTThrowingAttack' );

local BTThrowTree = {};

function BTThrowTree.new()
    local self = BTComposite.new():addInstance( 'BTThrowTree');

    local baseSequence = BTSequence.new();
    baseSequence:addNode( BTHasThrowingWeapon.new() );
    baseSequence:addNode( BTAquireTarget.new() );
    baseSequence:addNode( BTThrowingAttack.new() );

    self:addNode( baseSequence );

    return self;
end

return BTThrowTree;
