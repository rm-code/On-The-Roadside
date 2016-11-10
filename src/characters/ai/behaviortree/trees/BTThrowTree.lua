local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTHasThrowingWeapon = require( 'src.characters.ai.behaviortree.leafs.BTHasThrowingWeapon' );
local BTAquireTarget = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTGrenadeAttack = require( 'src.characters.ai.behaviortree.leafs.BTGrenadeAttack' );

local BTThrowTree = {};

function BTThrowTree.new()
    local self = BTComposite.new():addInstance( 'BTThrowTree');

    local baseSequence = BTSequence.new();
    baseSequence:addNode( BTHasThrowingWeapon.new() );
    baseSequence:addNode( BTAquireTarget.new() );
    baseSequence:addNode( BTGrenadeAttack.new() );

    self:addNode( baseSequence );

    return self;
end

return BTThrowTree;
