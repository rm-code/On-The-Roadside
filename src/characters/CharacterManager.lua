local Character = require( 'src.characters.Character' );
local Faction = require( 'src.characters.Faction' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CharacterManager = {};

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

function CharacterManager.newCharacter( tile, faction )
    factions[faction]:addCharacter( Character.new( tile, faction ));
end

function CharacterManager.nextCharacter()
    return factions[factionIndex]:nextCharacter();
end

function CharacterManager.prevCharacter()
    return factions[factionIndex]:prevCharacter();
end

function CharacterManager.getCurrentCharacter()
    return factions[factionIndex]:getCurrentCharacter();
end

function CharacterManager.selectCharacter( tile )
    if tile:isOccupied() then
        factions[factionIndex]:findCharacter( tile:getCharacter() );
    end
    return CharacterManager.getCurrentCharacter();
end

function CharacterManager.clearCharacters()
    for _, char in ipairs( factions[factionIndex] ) do
        char:resetActionPoints();
        char:clearActions();
        char:removePath();
        char:removeLineOfSight();
    end
end

function CharacterManager.getFaction()
    return factions[factionIndex];
end

function CharacterManager.nextFaction()
    factionIndex = factionIndex + 1 > #factions and 1 or factionIndex + 1;

    if factions[factionIndex]:getCurrentCharacter():isDead() then
        CharacterManager.nextCharacter();
    end
end

---
-- Removes dead characters from the game.
--
function CharacterManager.removeDeadActors()
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

return CharacterManager;
