local Character = require( 'src.characters.Character' );
local Faction = require( 'src.characters.Faction' );
local FactionNode = require( 'src.characters.FactionNode' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FactionManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local root;
local active;

local function addFaction( faction )
    local node = FactionNode.new( faction );

    -- Initialise root node.
    if not root then
        root = node;
        active = root;
        return;
    end

    -- Doubly link the new node.
    active:linkNext( node );
    node:linkPrev( active );

    -- Make it the active node.
    active = node;
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function FactionManager.init()
    addFaction( Faction.new( FACTIONS.ENEMY ));
    addFaction( Faction.new( FACTIONS.NEUTRAL ));
    addFaction( Faction.new( FACTIONS.ALLIED ));
end

function FactionManager.newCharacter( tile, faction )
    local node = root;
    while node do
        if node:getFaction():getType() == faction then
            node:getFaction():addCharacter( Character.new( tile, faction ));
            break;
        end
        node = node:getNext();
    end
end

function FactionManager.nextCharacter()
    return active:getFaction():nextCharacter();
end

function FactionManager.prevCharacter()
    return active:getFaction():prevCharacter();
end

function FactionManager.getCurrentCharacter()
    return active:getFaction():getCurrentCharacter();
end

function FactionManager.selectCharacter( tile )
    if tile:isOccupied() then
        active:getFaction():findCharacter( tile:getCharacter() );
    end
    return FactionManager.getCurrentCharacter();
end

function FactionManager.clearCharacters()
    for _, char in ipairs( active:getFaction() ) do
        char:resetActionPoints();
        char:clearActions();
        char:removePath();
        char:removeLineOfSight();
    end
end

function FactionManager.getFaction()
    return active:getFaction();
end

function FactionManager.nextFaction()
    while active do
        active = active:getNext() or root;
        if active:getFaction():hasLivingCharacters() then
            if active:getFaction():getCurrentCharacter():isDead() then
                return FactionManager.nextCharacter();
            end
            return active:getFaction():getCurrentCharacter();
        end
    end

end

---
-- Removes dead characters from the game.
--
function FactionManager.removeDeadActors()
    active:getFaction():iterate( function( character )
        if character:isDead() then
            local storage = character:getInventory():getSlots();
            local tile = character:getTile();

            for _, slot in ipairs( storage ) do
                if not slot:isEmpty() then
                    tile:getStorage():addItem( slot:getItem() );
                end
            end

            tile:removeCharacter();
        end
    end);
end

return FactionManager;
