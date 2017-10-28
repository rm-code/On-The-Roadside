local Log = require( 'src.util.Log' );
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
local NAME_FILE = 'res.data.Names'
local NATIONALITY = {
    { id = 'german',  weight = 10 },
    { id = 'russian', weight =  3 },
    { id = 'british', weight =  3 },
    { id = 'finnish', weight =  1 }
}

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local names
local nationalityWeight

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Load all names from the specified file.
-- @tparam string path The path pointing to the file to load.
--
local function loadNames( path )
    return require( path )
end

---
-- Calculates the total weight of all nationalities used for their random
-- selection.
-- @treturn number The total weight.
--
local function calculateNationalitiesWeight()
    local weight = 0
    for i = 1, #NATIONALITY do
        weight = weight + NATIONALITY[i].weight
    end
    return weight
end

---
-- Randomly chooses a nationality from the weighted list of nationalities.
-- @treturn string The selected nationality's id.
--
local function chooseNationality()
    local rnd = love.math.random( nationalityWeight )
    local weight = 0
    for i = 1, #NATIONALITY do
        weight = weight + NATIONALITY[i].weight
        if rnd <= weight then
            return NATIONALITY[i].id
        end
    end
    error( 'Random selection of nationality failed. No nationality found.' )
end

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

function CharacterFactory.init()
    Log.debug( "Load Creature-Names:" )
    names = loadNames( NAME_FILE )

    nationalityWeight = calculateNationalitiesWeight()
end

function CharacterFactory.loadCharacter( savedCharacter )
    local character = Character.new()

    character:setName( savedCharacter.name )
    character:setActionPoints( savedCharacter.actionPoints );
    character:setAccuracy( savedCharacter.accuracy );
    character:setThrowingSkill( savedCharacter.throwingSkill );
    character:setStance( savedCharacter.stance );
    character:setFinishedTurn( savedCharacter.finishedTurn );

    local body = BodyFactory.load( savedCharacter.body );
    character:setBody( body );

    -- TODO Remove hack for saving / loading characters
    character:setSavedPosition( savedCharacter.x, savedCharacter.y )

    return character;
end

function CharacterFactory.newCharacter( type )
    local character = Character.new()

    if type == 'human' then
        local nationality = chooseNationality()
        character:setNationality( nationality )
        character:setName( names[nationality][love.math.random( #names[nationality] )])
    end

    character:setBody( BodyFactory.create( type ));
    createEquipment( character );

    return character;
end

return CharacterFactory;
