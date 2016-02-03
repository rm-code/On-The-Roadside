local Character = require( 'src.characters.Character' );

local CharacterManager = {};

local characters = {};
local characterIndex = 1;

function CharacterManager.newCharacter( tile )
    characters[#characters + 1] = Character.new( tile );
end

function CharacterManager.nextCharacter()
    characterIndex = characterIndex + 1 > #characters and 1 or characterIndex + 1;
    return characters[characterIndex];
end

function CharacterManager.getCurrentCharacter()
    return characters[characterIndex];
end

function CharacterManager.selectCharacter( tile )
    for i = 1, #characters do
        if tile == characters[i]:getTile() then
            characterIndex = i;
        end
    end
end

return CharacterManager;
