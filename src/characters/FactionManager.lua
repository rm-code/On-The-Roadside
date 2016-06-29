local Character = require( 'src.characters.Character' );
local Faction = require( 'src.characters.Faction' );

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

local factions = {
    [FACTIONS.ALLIED]  = Faction.new(),
    [FACTIONS.NEUTRAL] = Faction.new(),
    [FACTIONS.ENEMY]   = Faction.new()
};

local factionIndex = 1;

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function FactionManager.newCharacter( tile, faction )
    factions[faction]:addCharacter( Character.new( tile, faction ));
end

function FactionManager.nextCharacter()
    return factions[factionIndex]:nextCharacter();
end

function FactionManager.prevCharacter()
    return factions[factionIndex]:prevCharacter();
end

function FactionManager.getCurrentCharacter()
    return factions[factionIndex]:getCurrentCharacter();
end

function FactionManager.selectCharacter( tile )
    if tile:isOccupied() then
        factions[factionIndex]:findCharacter( tile:getCharacter() );
    end
    return FactionManager.getCurrentCharacter();
end

function FactionManager.clearCharacters()
    for _, char in ipairs( factions[factionIndex] ) do
        char:resetActionPoints();
        char:clearActions();
        char:removePath();
        char:removeLineOfSight();
    end
end

function FactionManager.getFaction()
    return factions[factionIndex];
end

function FactionManager.nextFaction()
    factionIndex = factionIndex + 1 > #factions and 1 or factionIndex + 1;

    if factions[factionIndex]:getCurrentCharacter():isDead() then
        FactionManager.nextCharacter();
    end
end

---
-- Removes dead characters from the game.
--
function FactionManager.removeDeadActors()
    factions[factionIndex]:iterate( function( character )
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
