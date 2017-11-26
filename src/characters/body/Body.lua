---
-- The Body module is used to keep track of a creature's body parts and health
-- related stats. Each Body in the game is modelled as a graph with nodes being
-- the body parts and edges determining how the different parts are connected.
--
-- The body also contains a creature's the inventory and equipment.
--
-- @module Body
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Class = require( 'lib.Middleclass' )
local StatusEffects = require( 'src.characters.body.StatusEffects' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Body = Class( 'Body' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Ticks the bleeding effects on a node and applies the dead effect to the
-- creature if the blood volume is below zero.
-- @tparam Body     self     The body instance to use.
-- @tparam BodyPart bodyPart The bodypart to tick.
--
local function handleBleeding( self, bodyPart )
    if bodyPart:isBleeding() then
        self.curBloodVolume = self.curBloodVolume - bodyPart:getBloodLoss()
        if self.curBloodVolume <= 0 then
            Log.debug( 'Character bleeds to death!', 'Body' )
            self.statusEffects:add({ STATUS_EFFECTS.DEAD })
        end
    end
end

---
-- Checks if the body part's node is connected to an equipment slot and if
-- that equipment slot contains an item of the type clothing. If that's the
-- case it reduces the damage based on the type of damage and the type of
-- armor stats the item in the equipment slot has.
-- @tparam  Body     self       The body instance to use.
-- @tparam  BodyPart bodyPart   The body part to damage.
-- @tparam  number   damage     The amount of damage.
-- @treturn number              The modified damage value.
--
local function checkArmorProtection( self, bodyPart, damage )
    local slots = self.equipment:getSlots()
    for _, edge in ipairs( self.edges ) do
        local slot = slots[edge.from]
        -- If edge.from points to an equipment slot and the edge connects it
        -- to the body part currently receiving damage we check for armor.
        if slot and edge.to == bodyPart:getIndex() then
            -- Get the slot contains an item and the item is of type clothing we check
            -- if the attack actually hits a part that is covered by the armor.
            local item = slot:getItem()
            if item and item:instanceOf( 'Armor' ) then
                Log.debug( 'Body part is protected by armor ' .. item:getID(), 'Body' )
                if love.math.random( 0, 100 ) < item:getArmorCoverage() then
                    Log.debug( string.format( 'The armor absorbs %d points of damage.', item:getArmorProtection() ), 'Body' )
                    damage = damage - item:getArmorProtection()
                end
            end
        end
    end
    return damage
end

---
-- Picks a random entry node and returns it.
-- @tparam  Body     self The body instance to use.
-- @treturn BodyPart      The bodypart used as an entry point for the graph.
--
local function selectEntryNode( self )
    local entryNodes = {}
    for _, node in pairs( self.nodes ) do
        if node:isEntryNode() and not node:isDestroyed() then
            entryNodes[#entryNodes + 1] = node
        end
    end
    return entryNodes[love.math.random( #entryNodes )]
end

---
-- Destroys all child nodes. This is used when a parent body part is destroyed
-- and basically simulates how for example the destruction of an upper arm would
-- also mean the lower arm, hand and fingers are destroyed.
-- @tparam Body     self       The body instance to use.
-- @tparam BodyPart bodyPart   The body part to damage.
--
local function destroyChildNodes( self, bodyPart )
    bodyPart:destroy()

    -- Add status effects.
    self.statusEffects:add( bodyPart:getEffects() )

    -- Recursively destroy child nodes connected to the body part.
    for _, edge in ipairs( self.edges ) do
        if edge.from == bodyPart:getIndex() then
            destroyChildNodes( self, self.nodes[edge.to] )
        end
    end
end

---
-- Propagates the damage from parent to child nodes.
-- @tparam Body     self       The body instance to use.
-- @tparam BodyPart bodyPart   The body part to damage.
-- @tparam number   damage     The amount of damage.
-- @tparam string   damageType The type of damage.
--
local function propagateDamage( self, bodyPart, damage, damageType )
    damage = checkArmorProtection( self, bodyPart, damage )

    -- Stop damage propagation if the armor has stopped all of the incoming damage.
    if damage <= 0 then
        return
    end

    bodyPart:hit( damage, damageType )
    handleBleeding( self, bodyPart )

    -- Manually destroy child nodes if parent node is destroyed.
    if bodyPart:isDestroyed() then
        destroyChildNodes( self, bodyPart )
        return
    end

    -- Randomly propagate the damage to connected nodes.
    for _, edge in ipairs( self.edges ) do
        if edge.from == bodyPart:getIndex() and not self.nodes[edge.to]:isDestroyed() and love.math.random( 100 ) < tonumber( edge.name ) then
            propagateDamage( self, self.nodes[edge.to], damage, damageType )
        end
    end
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Initializes the Body instance.
-- @tparam string id          The creature's id.
-- @tparam number bloodVolume The creature's maximum blood volume.
-- @tparam table  tags        The creature's tags.
-- @tparam table  sizes       A table containing the creature's sizes mapped to its stances.
--
function Body:initialize( id, bloodVolume, tags, sizes )
    self.id = id

    self.maxBloodVolume = bloodVolume
    self.curBloodVolume = bloodVolume

    self.tags = tags
    self.sizes = sizes

    self.nodes = {}
    self.edges = {}

    self.statusEffects = StatusEffects.new()
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Adds a new body part to this body.
-- @tparam BodyPart bodyPart The body part to add.
--
function Body:addBodyPart( bodyPart )
    local index = bodyPart:getIndex()
    assert( not self.nodes[index], 'ID already used! BodyParts have to be unique.' )
    self.nodes[index] = bodyPart
end

---
-- Adds a new connection to this body. Connections are used to determine which
-- body parts are connected to each other and are represented by edges in the
-- body graph.
--
function Body:addConnection( connection )
    self.edges[#self.edges + 1] = connection
end

---
-- Updates the body once. This should be used to update status effects once per
-- round.
--
function Body:tickOneTurn()
    for _, node in pairs( self.nodes ) do
        if node:isBleeding() then
            handleBleeding( self, node )
        end
    end
end

---
-- Selects a random entry point for the damage and then propagates it along the
-- connections to the appropriate body parts.
-- @tparam number damage     The damage to apply to the body.
-- @tparam string damageType The type of damage to apply.
--
function Body:hit( damage, damageType )
    local entryNode = selectEntryNode( self )
    Log.debug( "Attack enters body at " .. entryNode:getID(), 'Body' )

    propagateDamage( self, entryNode, damage, damageType )
end

---
-- Serializes the Body.
--
function Body:serialize()
    local t = {
        ['id'] = self.id,
        ['inventory'] = self.inventory:serialize(),
        ['equipment'] = self.equipment:serialize(),
        ['statusEffects'] = self.statusEffects:serialize()
    }

    -- Serialize body graph's edges.
    t['edges'] = {}
    for i, edge in ipairs( self.edges ) do
        t['edges'][i] = {
            ['name'] = edge.name,
            ['from'] = edge.from,
            ['to'] = edge.to
        }
    end

    -- Serialize body graph's nodes.
    t['nodes'] = {}
    for i, node in ipairs( self.nodes ) do
        t['nodes'][i] = node:serialize()
    end

    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the current amount of blood volume the body has.
-- @treturn number The current amount of blood.
--
function Body:getBloodVolume()
    return self.curBloodVolume
end

---
-- Returns all body parts belonging to the body.
-- @treturn table A table containing the body parts.
--
function Body:getBodyParts()
    return self.nodes
end

---
-- Returns a specific body part.
-- @tparam  number   id The id of the body part to return.
-- @treturn BodyPart    The body part belonging to the specified id.
--
function Body:getBodyPart( id )
    return self.nodes[id]
end

---
-- Returns the creature's equipment.
-- @treturn Equipment The equipment.
--
function Body:getEquipment()
    return self.equipment
end

---
-- Returns the creature's height based on a certain stance.
-- @tparam  string stance The stance to get the height for.
-- @treturn number        The height based on the stance.
--
function Body:getHeight( stance )
    return self.sizes[stance]
end

---
-- Returns the creature's id.
-- @treturn string The creature's id.
function Body:getID()
    return self.id
end

---
-- Returns the creature's inventory.
-- @treturn Inventory The inventory.
--
function Body:getInventory()
    return self.inventory
end

---
-- Returns the active status effects.
-- @treturn StatusEffects The status effects for this body.
--
function Body:getStatusEffects()
    return self.statusEffects
end

---
-- Returns the body's tags.
-- @treturn table The body's tags.
--
function Body:getTags()
    return self.tags
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the inventory for this body.
-- @tparam Inventory inventory The new inventory.
--
function Body:setInventory( inventory )
    self.inventory = inventory
end

---
-- Sets the equipment for this body.
-- @tparam Equipment equipment The new equipment.
--
function Body:setEquipment( equipment )
    self.equipment = equipment
end

return Body
