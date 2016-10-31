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
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.WEAPON   ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.BAG      ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.HEADGEAR ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.GLOVES   ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.SHIRT    ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.JACKET   ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.TROUSERS ));
    character:getInventory():addItem( ItemFactory.createRandomItem( ITEM_TYPES.FOOTWEAR ));

    local weapon = character:getInventory():getWeapon();

    if weapon:getWeaponType() == 'Melee' or weapon:getWeaponType() == 'Grenade' then
        return;
    end

    local amount = weapon:getMagazine():getCapacity();
    for _ = 1, amount do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        weapon:getMagazine():addRound( round );
    end

    amount = weapon:getMagazine():getCapacity() * 2;
    for _ = 1, amount do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        character:getInventory():getBackpack():getInventory():addItem( round );
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.loadCharacter( map, tile, faction )
    local character = Character.new( map, tile, faction );
    character:generateFOV();
    return character;
end

function CharacterFactory.newCharacter( map, tile, faction )
    local character = Character.new( map, tile, faction );
    createEquipment( character );
    character:generateFOV();
    return character;
end

return CharacterFactory;
