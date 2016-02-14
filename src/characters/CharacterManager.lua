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

function CharacterManager.getCharacters()
    return factions[factionIndex];
end

function CharacterManager.nextFaction()
    factionIndex = factionIndex + 1 > #factions and 1 or factionIndex + 1;
    characterIndex = 1;
end

return CharacterManager;
