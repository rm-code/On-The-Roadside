local Log = require( 'src.util.Log' );
local TGFParser = require( 'lib.TGFParser' );

local BehaviorTreeFactory = {};

local TEMPLATE_DIRECTORY = 'res/data/creatures/ai/';
local TEMPLATE_EXTENSION = 'tgf';
local BLUEPRINTS = {
    ['Selector']             = require( 'src.characters.ai.behaviortree.composite.BTSelector' ),
    ['Sequence']             = require( 'src.characters.ai.behaviortree.composite.BTSequence' ),
    ['BTAquireTarget']       = require( 'src.characters.ai.behaviortree.leafs.BTAquireTarget' ),
    ['BTAttackTarget']       = require( 'src.characters.ai.behaviortree.leafs.BTAttackTarget' ),
    ['BTCanAttack']          = require( 'src.characters.ai.behaviortree.leafs.BTCanAttack' ),
    ['BTCanReload']          = require( 'src.characters.ai.behaviortree.leafs.BTCanReload' ),
    ['BTCanSeeItem']         = require( 'src.characters.ai.behaviortree.leafs.BTCanSeeItem' ),
    ['BTHasMeleeWeapon']     = require( 'src.characters.ai.behaviortree.leafs.BTHasMeleeWeapon' ),
    ['BTHasRangedWeapon']    = require( 'src.characters.ai.behaviortree.leafs.BTHasRangedWeapon' ),
    ['BTHasThrowingWeapon']  = require( 'src.characters.ai.behaviortree.leafs.BTHasThrowingWeapon' ),
    ['BTHasWeapon']          = require( 'src.characters.ai.behaviortree.leafs.BTHasWeapon' ),
    ['BTIsAdjacentToTarget'] = require( 'src.characters.ai.behaviortree.leafs.BTIsAdjacentToTarget' ),
    ['BTMeleeAttack']        = require( 'src.characters.ai.behaviortree.leafs.BTMeleeAttack' ),
    ['BTMoveToTarget']       = require( 'src.characters.ai.behaviortree.leafs.BTMoveToTarget' ),
    ['BTMustReload']         = require( 'src.characters.ai.behaviortree.leafs.BTMustReload' ),
    ['BTRandomMovement']     = require( 'src.characters.ai.behaviortree.leafs.BTRandomMovement' ),
    ['BTRearm']              = require( 'src.characters.ai.behaviortree.leafs.BTRearm' ),
    ['BTReload']             = require( 'src.characters.ai.behaviortree.leafs.BTReload' ),
    ['BTTakeItem']           = require( 'src.characters.ai.behaviortree.leafs.BTTakeItem' ),
    ['BTThrowingAttack']     = require( 'src.characters.ai.behaviortree.leafs.BTThrowingAttack' )
}

local trees;

---
-- Returns a list of all files inside the specified directory.
-- @param dir (string) The directory to load the templates from.
-- @return    (table)  A sequence containing all files in the directory.
--
local function loadFiles( dir )
    local files = {};
    for i, file in ipairs( love.filesystem.getDirectoryItems( dir )) do
        local fn, fe = file:match( '^(.+)%.(.+)$' );
        if fe == TEMPLATE_EXTENSION then
            files[#files + 1] = { name = fn, extension = fe };
            Log.debug( string.format( '%3d. %s.%s', i, fn, fe ), 'BehaviorTreeFactory' );
        end
    end
    return files;
end

---
-- Loads all
-- @param files (table) A sequence containing all files in the directory.
-- @return      (table) A table containing the converted templates.
--
local function parseFiles( files )
    local tmp = {};
    for _, file in ipairs( files ) do
        local path = string.format( '%s%s.%s', TEMPLATE_DIRECTORY, file.name, file.extension );
        local status, template = pcall( TGFParser.parse, path );
        if not status then
            Log.warn( 'Can not load ' .. path, 'BehaviorTreeFactory' );
        else
            tmp[file.name] = template;
        end
    end
    return tmp;
end

local function createTree( layout )
    local nodes = {};

    for _, node in ipairs( layout.nodes ) do
        assert( BLUEPRINTS[node.label], string.format( 'Behavior blueprint %s does not exist!', node.label ))
        nodes[node.id] = BLUEPRINTS[node.label]()
    end

    for _, edge in ipairs( layout.edges ) do
        local from, to = nodes[edge.from], nodes[edge.to];
        from:addNode( to, tonumber( edge.label ))
    end

    return nodes[1];
end

local function createTrees( layouts )
    for i, layout in pairs( layouts ) do
        Log.debug( string.format( 'Creating %s behavior tree...', i ), 'BehaviorTreeFactory' );
        trees[i] = createTree( layout );
    end
end

---
-- Loads the templates.
--
function BehaviorTreeFactory.loadTemplates()
    Log.debug( "Load Behavior Trees:" )
    local files = loadFiles( TEMPLATE_DIRECTORY );
    local treeLayouts = parseFiles( files );

    trees = {};
    createTrees( treeLayouts );
end

function BehaviorTreeFactory.getTree( type )
    assert( trees[type], 'No behavior tree found for ' .. tostring( type ));
    return trees[type];
end

return BehaviorTreeFactory;
