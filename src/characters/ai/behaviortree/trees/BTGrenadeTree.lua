local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );
local BTSequence = require( 'src.characters.ai.behaviortree.composite.BTSequence' );
local BTHasGrenade = require( 'src.characters.ai.behaviortree.leafs.BTHasGrenade' );
local BTAquireTarget = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' );
local BTGrenadeAttack = require( 'src.characters.ai.behaviortree.leafs.BTGrenadeAttack' );

local BTGrenadeTree = {};

function BTGrenadeTree.new()
    local self = BTComposite.new():addInstance( 'BTGrenadeTree');

    local baseSequence = BTSequence.new();
    baseSequence:addNode( BTHasGrenade.new() );
    baseSequence:addNode( BTAquireTarget.new() );
    baseSequence:addNode( BTGrenadeAttack.new() );

    self:addNode( baseSequence );

    return self;
end

return BTGrenadeTree;
