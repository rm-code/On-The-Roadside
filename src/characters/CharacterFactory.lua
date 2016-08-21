local Character = require( 'src.characters.Character' );
local ItemFactory = require('src.items.ItemFactory');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CharacterFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require( 'src.constants.ItemTypes' );

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Creates the equipment for a character.
-- @param character (Character) The character to equip with new items.
--
local function createEquipment( character )
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.WEAPON   ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.BAG      ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.HEADGEAR ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.GLOVES   ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.SHIRT    ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.JACKET   ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.TROUSERS ));
    character:getEquipment():addItem( ItemFactory.createRandomItem( ITEM_TYPES.FOOTWEAR ));

    local weapon = character:getEquipment():getWeapon();
    local magazine;
    for _ = 1, 3 do
        magazine = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getCaliber() );
        magazine:setCapacity( weapon:getMagSize() );
        magazine:setRounds( weapon:getMagSize() );
        character:getEquipment():getBackpack():getInventory():addItem( magazine );
    end
    weapon:reload( magazine );
    character:getEquipment():getBackpack():getInventory():removeItem( magazine );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.newCharacter( map, tile, faction )
    local character = Character.new( map, tile, faction );
    createEquipment( character );
    character:generateFOV();
    return character;
end

return CharacterFactory;
