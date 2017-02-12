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
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads the character's weapon and adds ammunition to his inventory.
-- @param weapon   (Weapon) The weapon to load.
-- @param backpack (Bag)    The equipment to create ammunition for.
--
local function createAmmunition( weapon, backpack )
    -- Load the weapon.
    local amount = weapon:getMagazine():getCapacity();
    for _ = 1, amount do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        weapon:getMagazine():addRound( round );
    end

    -- Add twice the amount of ammunition to the inventory.
    for _ = 1, amount * 2 do
        local round = ItemFactory.createItem( ITEM_TYPES.AMMO, weapon:getMagazine():getCaliber() );
        backpack:getInventory():addItem( round );
    end
end

---
-- Creates the equipment for a character.
-- @param character (Character) The character to equip with new items.
--
local function createEquipment( character )
    local equipment = character:getEquipment();
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.WEAPON   ));
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.BAG      ));
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.HEADGEAR ));
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.JACKET   ));
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.TROUSERS ));
    equipment:addItem( ItemFactory.createRandomItem( ITEM_TYPES.FOOTWEAR ));

    local weapon = character:getWeapon();
    local backpack = character:getBackpack();
    if weapon:isReloadable() then
        createAmmunition( weapon, backpack );
    elseif weapon:getWeaponType() == WEAPON_TYPES.THROWN then
        backpack:getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
        backpack:getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
        backpack:getInventory():addItem( ItemFactory.createItem( ITEM_TYPES.WEAPON, weapon:getID() ));
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
    local character = Character.new( map, tile, faction, 'human' );
    createEquipment( character );
    character:generateFOV();
    return character;
end

return CharacterFactory;
