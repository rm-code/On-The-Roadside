---
-- @module CharacterFactory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Character = require( 'src.characters.Character' )
local BodyFactory = require( 'src.characters.body.BodyFactory' )
local ItemFactory = require( 'src.items.ItemFactory' )
local Util = require( 'src.util.Util' )
local Translator = require( 'src.util.Translator' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CharacterFactory = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )
local ITEM_TYPES = require( 'src.constants.ITEM_TYPES' )
local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

local CREATURE_CLASSES = require( 'res.data.creatures.classes' )
local CREATURE_GROUPS = require( 'res.data.creatures.groups' )
local CREATURE_NAMES = require( 'res.data.creatures.names' )
local NATIONALITY = {
    { id = 'nationality_german',  weight = 10 },
    { id = 'nationality_russian', weight =  3 },
    { id = 'nationality_british', weight =  3 },
    { id = 'nationality_finnish', weight =  1 }
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
    return Util.pickRandomValue( CREATURE_NAMES[nationality] )
end

---
-- Creates the equipment for a character.
-- @tparam Character character   The character to equip with new items.
-- @tparam string    factionType The type of faction this character is created for.
--
local function createEquipment( character, factionType )
    local body = character:getBody()
    local equipment = body:getEquipment()
    local inventory = body:getInventory()
    local tags = body:getTags()

    Log.debug( string.format( 'Creating equipment [class: %s, id: %s, faction: %s]', character:getCreatureClass(), body:getID(), factionType ), 'CharacterFactory' )

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
    if weapon:getSubType() == WEAPON_TYPES.THROWN then
        inventory:addItem( ItemFactory.createItem( weapon:getID() ))
        inventory:addItem( ItemFactory.createItem( weapon:getID() ))
        inventory:addItem( ItemFactory.createItem( weapon:getID() ))
    end
end

---
-- Searches and returns a body type for a specific class.
-- @tparam string classID The class id to look for.
-- @tparam string The body type for the provided class.
--
local function findClass( classID )
    for _, class in ipairs( CREATURE_CLASSES ) do
        if class.id == classID then
            return class
        end
    end
end

---
-- Picks a random creature class based on the faction.
-- @tparam string factionID The faction id to select from.
-- @treturn string The class id.
--
local function pickCreatureClass( factionID )
    return Util.pickRandomValue( CREATURE_GROUPS[factionID] )
end

---
-- Rolls a random number between the min and max value.
-- @tparam number min The minimum possible value.
-- @tparam number max The maximum possible value.
-- @tparam number     The rolled number.
--
local function rollStat( min, max )
    return love.math.random( min, max )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function CharacterFactory.init()
    nationalityWeight = calculateNationalitiesWeight()
end

function CharacterFactory.loadCharacter( savedCharacter )
    local character = Character( savedCharacter.class,
                                 savedCharacter.maximumAP,
                                 savedCharacter.viewRange,
                                 savedCharacter.shootingSkill,
                                 savedCharacter.throwingSkill )

    character:setName( savedCharacter.name )
    character:setCurrentAP( savedCharacter.currentAP )
    character:setStance( savedCharacter.stance )
    character:setFinishedTurn( savedCharacter.finishedTurn )
    character:setPosition( savedCharacter.x, savedCharacter.y )
    character:setNationality( savedCharacter.nationality )
    character:setMissionCount( savedCharacter.missions )

    local body = BodyFactory.load( savedCharacter.body )
    character:setBody( body )

    return character
end

function CharacterFactory.newCharacter( factionType )
    local classID = pickCreatureClass( factionType )
    local class = findClass( classID )

    local shootingSkill = rollStat( class.stats.shootingSkill.min, class.stats.shootingSkill.max )
    local throwingSkill = rollStat( class.stats.throwingSkill.min, class.stats.throwingSkill.max )

    local character = Character( classID, class.stats.ap, class.stats.viewRange, shootingSkill, throwingSkill )

    local bodyType = Util.pickRandomValue( class.body )
    if bodyType == 'body_human' then
        local nationality = chooseNationality()
        character:setNationality( nationality )
        character:setName( generateName( nationality ))
    else
        character:setName( Translator.getText( classID ))
    end

    character:setBody( BodyFactory.create( bodyType, class.stats ))
    createEquipment( character, factionType )

    return character
end

return CharacterFactory
