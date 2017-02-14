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
    ['BTThrowingAttack']     = require( 'src.characters.ai.behaviortree.leafs.BTThrowingAttack' )
}

local treeLayouts;

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
            Log.debug( string.format( '%3d. %s.%s', i, fn, fe ));
        else
            Log.warn( string.format( 'Tried to load file %s.%s', fn, fe ));
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
            Log.warn( 'Can not load ' .. path );
        else
            tmp[file.name] = template;
        end
    end
    return tmp;
end

local function createTree( layout )
    local nodes = {};

    for index, id in ipairs( layout.nodes ) do
        nodes[index] = BLUEPRINTS[id].new();
        Log.debug( string.format( 'Created behavior tree node: %d, %s', index, id ));
    end

    for _, edge in ipairs( layout.edges ) do
        local from, to = nodes[edge.from], nodes[edge.to];
        from:addNode( to, tonumber( edge.name ));
        Log.debug( string.format( 'Added node %s to %s as %d', edge.from, edge.to, tonumber( edge.name )));
    end

    return nodes[1];
end

---
-- Loads the templates.
--
function BehaviorTreeFactory.loadTemplates()
    Log.debug( "Load Creature-Templates:" )
    local files = loadFiles( TEMPLATE_DIRECTORY );
    treeLayouts = parseFiles( files );
end

function BehaviorTreeFactory.create()
    return createTree( treeLayouts['enemy'] );
end

return BehaviorTreeFactory;
