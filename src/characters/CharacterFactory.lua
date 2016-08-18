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
    local weapon = ItemFactory.createWeapon();
    local magazine = ItemFactory.createMagazine( weapon:getCaliber(), weapon:getMagSize() );
    weapon:reload( magazine );

    character:getEquipment():addItem( weapon );
    character:getEquipment():addItem( ItemFactory.createBag() );
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.HEADGEAR ));
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.GLOVES   ));
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.SHIRT    ));
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.JACKET   ));
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.TROUSERS ));
    character:getEquipment():addItem( ItemFactory.createClothing( ITEM_TYPES.FOOTWEAR ));

    character:getEquipment():getBackpack():getInventory():addItem( ItemFactory.createMagazine( weapon:getCaliber(), weapon:getMagSize() ));
    character:getEquipment():getBackpack():getInventory():addItem( ItemFactory.createMagazine( weapon:getCaliber(), weapon:getMagSize() ));
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.createCharacter( map, tile, faction )
    local character = Character.new( map, tile, faction );
    createEquipment( character );
    character:generateFOV();
    return character;
end

return CharacterFactory;
