local Character = require( 'src.characters.Character' );
local BodyFactory = require( 'src.characters.body.BodyFactory' );
local ItemFactory = require('src.items.ItemFactory');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CharacterFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads the character's weapon and adds ammunition to his inventory.
-- @param weapon    (Weapon) The weapon to load.
-- @param inventory (Container)    The inventory to create ammunition for.
--
local function createAmmunition( weapon, inventory )
    -- Load the weapon.
    local amount = weapon:getMagazine():getCapacity();
    for _ = 1, amount do
        local round = ItemFactory.createItem( weapon:getMagazine():getCaliber() );
        weapon:getMagazine():addRound( round );
    end

    -- Add twice the amount of ammunition to the inventory.
    for _ = 1, amount * 2 do
        local round = ItemFactory.createItem( weapon:getMagazine():getCaliber() );
        inventory:addItem( round );
    end
end

---
-- Creates the equipment for a character.
-- @param character (Character) The character to equip with new items.
--
local function createEquipment( character )
    local body = character:getBody();
    local equipment = body:getEquipment();
    local tags = body:getTags();

    for _, slot in pairs( equipment:getSlots() ) do
        equipment:addItem( slot, ItemFactory.createRandomItem( tags, slot:getItemType(), slot:getSubType() ));
    end

    local weapon, inventory = character:getWeapon(), character:getInventory();
    if weapon:isReloadable() then
        createAmmunition( weapon, inventory );
    elseif weapon:getSubType() == WEAPON_TYPES.THROWN then
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.loadCharacter( map, tile, faction, savedCharacter )
    local character = Character.new( map, tile, faction );
    character:setActionPoints( savedCharacter.actionPoints );
    character:setAccuracy( savedCharacter.accuracy );
    character:setThrowingSkill( savedCharacter.throwingSkill );
    character:setStance( savedCharacter.stance );
    character:setFinishedTurn( savedCharacter.finishedTurn );

    local body = BodyFactory.load( savedCharacter.body );
    character:setBody( body );
    return character;
end

function CharacterFactory.newCharacter( map, tile, faction, type )
    local character = Character.new( map, tile, faction );
    character:setBody( BodyFactory.create( type ));
    createEquipment( character );
    return character;
end

return CharacterFactory;
