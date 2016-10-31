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
-- Loads the character's weapon and adds ammunition to his inventory.
-- @param character (Character) The character to create ammunition for.
-- @param weapon    (Weapon)    The weapon to load.
--
local function createAmmunition( character, weapon )
    -- Load the weapon.
    local amount = weapon:getMagazine():getCapacity();
    for _ = 1, amount do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        weapon:getMagazine():addRound( round );
    end

    -- Add twice the amount of ammunition to the inventory.
    for _ = 1, amount * 2 do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        character:getInventory():getBackpack():getInventory():addItem( round );
    end
end

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
    if weapon:isReloadable() then
        createAmmunition( character, weapon );
    elseif weapon:getWeaponType() == 'Thrown' then
        character:getInventory():getBackpack():getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
        character:getInventory():getBackpack():getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
        character:getInventory():getBackpack():getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
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
