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

local FACTIONS = require( 'src.constants.FACTIONS' )
local ITEM_TYPES = require( 'src.constants.ITEM_TYPES' )
local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

local CREATURE_CLASSES = require( 'res.data.creatures.classes' )
local CREATURE_NAMES = require( 'res.data.creatures.names' )
local NATIONALITY = {
    { id = 'german',  weight = 10 },
    { id = 'russian', weight =  3 },
    { id = 'british', weight =  3 },
    { id = 'finnish', weight =  1 }
}

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local nationalityWeight

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

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
-- Select a random name from the templates for the specified nationality.
-- @tparam string nationality The nationality to generate a name for.
-- @treturn name The generated name.
--
local function generateName( nationality )
    return CREATURE_NAMES[nationality][love.math.random( #CREATURE_NAMES[nationality] )]
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
-- @tparam Character character   The character to equip with new items.
-- @tparam string    factionType The type of faction this character is created for.
--
local function createEquipment( character, factionType )
    local body = character:getBody();
    local equipment = body:getEquipment();
    local inventory = body:getInventory()
    local tags = body:getTags();

    for _, slot in pairs( equipment:getSlots() ) do
        -- The player's characters should start mainly with guns. Shurikens, grenades
        -- and melee weapons should added as secondary weaponry.
        if factionType == FACTIONS.ALLIED and slot:getItemType() == ITEM_TYPES.WEAPON then
            equipment:addItem( slot, ItemFactory.createRandomItem( tags, slot:getItemType(), WEAPON_TYPES.RANGED ))

            -- Additionally add either a melee or some throwing weapons.
            if love.math.random() > 0.5 then
                inventory:addItem( ItemFactory.createRandomItem( tags, ITEM_TYPES.WEAPON, WEAPON_TYPES.MELEE ))
            else
                inventory:addItem( ItemFactory.createRandomItem( tags, ITEM_TYPES.WEAPON, WEAPON_TYPES.THROWN ))
                inventory:addItem( ItemFactory.createRandomItem( tags, ITEM_TYPES.WEAPON, WEAPON_TYPES.THROWN ))
                inventory:addItem( ItemFactory.createRandomItem( tags, ITEM_TYPES.WEAPON, WEAPON_TYPES.THROWN ))
            end
        else
            equipment:addItem( slot, ItemFactory.createRandomItem( tags, slot:getItemType(), slot:getSubType() ))
        end
    end

    local weapon = character:getWeapon()
    if weapon:isReloadable() then
        createAmmunition( weapon, inventory );
    elseif weapon:getSubType() == WEAPON_TYPES.THROWN then
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
        inventory:addItem( ItemFactory.createItem( weapon:getID() ));
    end
end

---
-- Searches and returns a body type for a specific class.
-- @tparam string classID The class id to look for.
-- @tparam string The body type for the provided class.
--
local function findBodyType( classID )
    for _, class in ipairs( CREATURE_CLASSES ) do
        if class.id == classID then
            return class.body[love.math.random( #class.body )]
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.init()
    nationalityWeight = calculateNationalitiesWeight()
end

function CharacterFactory.loadCharacter( savedCharacter )
    local character = Character()

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

function CharacterFactory.newCharacter( classID, factionType )
    local character = Character( classID )

    local bodyType = findBodyType( classID )
    if bodyType == 'human' then
        local nationality = chooseNationality()
        character:setNationality( nationality )
        character:setName( generateName( nationality ))
    end

    character:setBody( BodyFactory.create( bodyType ))
    createEquipment( character, factionType )

    return character;
end

return CharacterFactory;
