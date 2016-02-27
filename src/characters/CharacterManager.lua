local Character = require( 'src.characters.Character' );

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
    [FACTIONS.ALLIED]  = {},
    [FACTIONS.NEUTRAL] = {},
    [FACTIONS.ENEMY]   = {}
};

local characterIndex = 1;
local factionIndex = 1;


-- ------------------------------------------------
-- Local Function
-- ------------------------------------------------

---
-- Removes all dead characters from the game.
-- We iterate from the top so that we can remove the character and shift keys
-- without breaking the iteration. We also need to remove the dead each chars
-- from the tile they last occupied.
--
function CharacterManager.removeDeadActors()
    for _, faction in pairs( factions ) do
        for i = #faction, 1, -1 do
            local character = faction[i];
            if character:isDead() then
                character:getTile():removeCharacter();
                table.remove( faction, i );
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterManager.newCharacter( tile, faction )
    table.insert( factions[faction], Character.new( tile, faction ) );
end

function CharacterManager.nextCharacter()
    characterIndex = characterIndex + 1 > #factions[factionIndex] and 1 or characterIndex + 1;
    return CharacterManager.getCurrentCharacter();
end

function CharacterManager.getCurrentCharacter()
    return factions[factionIndex][characterIndex];
end

function CharacterManager.selectCharacter( tile )
    for i = 1, #factions[factionIndex] do
        if tile == factions[factionIndex][i]:getTile() then
            characterIndex = i;
        end
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

function CharacterManager.getCharacters()
    return factions[factionIndex];
end

function CharacterManager.nextFaction()
    factionIndex = factionIndex + 1 > #factions and 1 or factionIndex + 1;
    characterIndex = 1;
end

return CharacterManager;
