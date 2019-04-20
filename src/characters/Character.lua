---
-- @module Character
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local MapObject = require( 'src.map.MapObject' )
local Log = require( 'src.util.Log' )
local Queue = require('src.util.Queue')
local Bresenham = require( 'lib.Bresenham' )
local Util = require( 'src.util.Util' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Character = MapObject:subclass( 'Character' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STANCES = require( 'src.constants.STANCES' )
local ITEM_TYPES = require( 'src.constants.ITEM_TYPES' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Marks a tile as seen by this character if it fullfills the necessary
-- requirements. Used as a callback for Bresenham's line algorithm.
-- @tparam  number    cx      The tile's coordinate along the x-axis.
-- @tparam  number    cy      The tile's coordinate along the y-axis.
-- @tparam  number    counter The number of tiles touched by the ray so far.
-- @tparam  Character self    The character instance to use.
-- @tparam  number    falloff Determines how much height the ray loses each step.
-- @treturn boolean           Returns true if the tile can be seen by the character.
--
local function markSeenTiles( cx, cy, counter, self, falloff )
    local target = self.map:getTileAt( cx, cy )
    if not target then
        return false
    end

    -- Calculate the height of the ray on the current tile. If the height
    -- is smaller than the tile's height it is marked as visible. This
    -- simulates how small objects can be hidden behind bigger objects, but
    -- not the other way around.
    local height = self:getHeight() - (counter+1) * falloff
    if height <= target:getHeight() then
        -- Add tile to this character's FOV.
        self:addSeenTile( target )

        -- Mark tile for drawing update.
        target:setDirty( true )
    end

    -- A world object blocks vision if it has the "blocksVision" flag set
    -- to true in its template file and if the ray is smaller than the world
    -- object's size. This prevents characters from looking over bigger world
    -- objects and allows smaller objects like low walls to cast a "shadow"
    -- in which smaller objects could be hidden.
    if  target:hasWorldObject()
    and target:getWorldObject():doesBlockVision()
    and height <= target:getWorldObject():getHeight() then
        return false
    end

    return true
end

---
-- Determine the height falloff for rays of the FOV calculation. This value
-- will be deducted from the ray's height for each tile the ray traverses.
-- @tparam  number characterHeight The character's height.
-- @tparam  number targetHeight    The target's height.
-- @tparam  number steps           The amount of steps between the character and the target.
-- @treturn number The calculated falloff value.
--
local function calculateFalloff( characterHeight, targetHeight, steps )
    return (characterHeight - targetHeight) / steps
end

---
-- Clears the list of seen tiles and marks them for a drawing update.
-- @tparam table  fov         The table containing the tiles the character can see.
-- @tparam string factionType The faction's id as defined in the faction constants.
--
local function resetFOV( fov, factionType )
    for target, _ in pairs( fov ) do
        target:setDirty( true )
        target:decrementFactionFOV( factionType )
        fov[target] = nil
    end
end

---
-- Drops all inventory and equipment items, removes the character from
-- the tile and resets the FOV information for this character.
-- @tparam Character self The character instance to use.
--
local function handleDeath( self )
    self:getEquipment():dropAllItems( self:getTile() )
    self:getInventory():dropAllItems( self:getTile() )
    self.map:removeCharacter( self.x, self.y, self )
    resetFOV( self.fov, self:getFaction():getType() )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Character:initialize( classID, actionPoints, viewRange, shootingSkill, throwingSkill )
    MapObject.initialize( self )

    self.creatureClass = classID

    self.maximumAP = actionPoints
    self.currentAP = self.maximumAP

    self.actions = Queue()

    self.fov = {}
    self.viewRange = viewRange

    self.shootingSkill = shootingSkill
    self.throwingSkill = throwingSkill

    self.missions = 0

    self.stance = STANCES.STAND

    self.finishedTurn = false
end

---
-- Called when this character is made active by the game.
--
function Character:activate()
    if self:isDead() then
        return
    end
    self:generateFOV()
    self:clearActions()

    self:publish( 'CHARACTER_SELECTED', self:getTile() )
end

---
-- Called when this character is made inactive by the game.
--
function Character:deactivate()
    if self:isDead() then
        return
    end
    self:generateFOV()
    self:clearActions()
end

---
-- Adds a tile to this character's FOV.
-- @tparam Tile target The target-tile.
--
function Character:addSeenTile( target )
    -- Update the faction FOV for the tile if it hasn't been seen by this
    -- character already.
    if not self.fov[target] then
        target:incrementFactionFOV( self:getFaction():getType() )
    end

    self.fov[target] = true
end

---
-- Adds a new action to the action queue if the character has enough action
-- points to perform it.
-- @tparam  Action  newAction The action to enqueue.
-- @treturn boolean           True if the action was enqueued.
--
function Character:enqueueAction( newAction )
    local cost = 0
    for _, action in ipairs( self.actions:getItems() ) do
        cost = cost + action:getCost()
    end

    -- Enqueue action only if the character has enough action points left.
    if cost + newAction:getCost() <= self.currentAP then
        self.actions:enqueue( newAction )
        return true
    end

    self:getTile():publish( 'MESSAGE_LOG_EVENT', self:getTile(), Translator.getText( 'msg_character_no_ap_left' ), 'DANGER' )
    Log.debug( 'No AP left. Refused to add Action to Queue.', 'Character' )
    return false
end

---
-- Removes the next action from the action queue, reduces the action points
-- of the character by the action's cost and performs the action.
--
function Character:performAction()
    local action = self.actions:dequeue()
    local success = action:perform()
    if success then
        self.currentAP = self.currentAP - action:getCost()
    end
    self:generateFOV()
end

---
-- Clears the action queue.
--
function Character:clearActions()
    self.actions:clear()
end

---
-- Casts rays in a circle around the character to determine all tiles he can
-- see. Rays stop if they reach the map border or a world object which has
-- the blocksVision attribute set to true.
--
function Character:generateFOV()
    resetFOV( self.fov, self:getFaction():getType() )

    local range = self.body:getStatusEffects():isBlind() and 1 or self:getViewRange()
    local list = Util.getTilesInCircle( self.map, self:getTile(), range )
    local sx, sy = self:getTile():getPosition()

    for _, tile in ipairs( list ) do
        local tx, ty = tile:getPosition()
        local _, counter = Bresenham.line( sx, sy, tx, ty )
        local falloff = calculateFalloff( self:getHeight(), tile:getHeight(), counter )
        Bresenham.line( sx, sy, tx, ty, markSeenTiles, self, falloff )
    end
end

---
-- Resets the character's action points to the default value.
--
function Character:resetCurrentAP()
    self.currentAP = self.maximumAP
end

---
-- Hits the character with damage.
-- @tparam number damage     The amount of damage the character is hit with.
-- @tparam string damageType The type of damage the tile is hit with.
--
function Character:hit( damage, damageType )
    self.body:hit( damage, damageType )

    self:generateFOV()

    if self:isDead() then
        handleDeath( self )
    end
end

---
-- Checks if the character can see a certain tile.
-- @tparam  Tile    target The tile to check.
-- @treturn boolean        Wether the character sees the tile.
--
function Character:canSee( target )
    return self.fov[target] == true
end

---
-- Moves the character to the new position on the map.
-- @tparam number x The target position along the x-axis.
-- @tparam number y The target position along the y-axis.
--
function Character:move( x, y )
    self.map:moveCharacter( x, y, self )
    self:publish( 'CHARACTER_MOVED', self:getTile() )
end

---
-- Increments the mission counter.
--
function Character:incrementMissionCount()
    self.missions = self.missions + 1
end

---
-- Serializes the Character instance.
-- @treturn table The serialized character instance.
--
function Character:serialize()
    local t = {
        ['class'] = self.creatureClass,
        ['name'] = self.name,
        ['nationality'] = self.nationality,
        ['maximumAP'] = self.maximumAP,
        ['currentAP'] = self.currentAP,
        ['viewRange'] = self.viewRange,
        ['shootingSkill'] = self.shootingSkill,
        ['throwingSkill'] = self.throwingSkill,
        ['stance'] = self.stance,
        ['finishedTurn'] = self.finishedTurn,
        ['missions'] = self.missions,
        ['body'] = self.body:serialize(),
        ['x'] = self.x,
        ['y'] = self.y
    }
    return t
end

---
-- Receives events by observed objects.
-- @tparam string event The event type.
-- @tparam varags ... Additional parameters to pass along.
--
function Character:receive( event, ... )
    self:getTile():publish( event, self:getTile(), ... )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the shooting skill of this character.
-- @treturn number The character's shooting skill.
--
function Character:getShootingSkill()
    return self.shootingSkill
end

---
-- Returns the amount of action points.
-- @treturn number The amount of action points.
--
function Character:getCurrentAP()
    return self.currentAP
end

---
-- Returns the action queue.
-- @return table A sequence containing all actions.
--
function Character:getActions()
    return self.actions:getItems()
end

---
-- Returns the action queue.
-- @treturn Queue A queue containing all actions.
--
function Character:getActionQueue()
    return self.actions
end

---
-- Returns the character's body.
-- @treturn Body The character's body.
--
function Character:getBody()
    return self.body
end

---
-- Returns the character's class type.
-- @treturn string The character's class.
--
function Character:getCreatureClass()
    return self.creatureClass
end

---
-- Returns the faction the character belongs to.
-- @treturn Faction The Faction object.
--
function Character:getFaction()
    return self.faction
end

---
-- Returns the character's equipment.
-- @treturn Equipment The character's equipment.
--
function Character:getEquipment()
    return self.body:getEquipment()
end

---
-- Returns the character's inventory.
-- @treturn Equipment The character's inventory.
--
function Character:getInventory()
    return self.body:getInventory()
end

---
-- Returns the character's fov.
-- @treturn table A table containing the tiles this character sees.
--
function Character:getFOV()
    return self.fov
end

---
-- Returns the creature's health.
-- @treturn number The current health points.
--
function Character:getCurrentHP()
    return self.body:getCurrentHP()
end

---
-- Returns the creature's maximum health.
-- @treturn number The maximum health points.
--
function Character:getMaximumHP()
    return self.body:getMaximumHP()
end

---
-- Returns the amount of missions a character has fought in.
-- @treturn number The number of missions.
--
function Character:getMissionCount()
    return self.missions
end

---
-- Gets the name of this character.
-- @treturn string The character's name.
--
function Character:getName()
    return self.name
end

---
-- Returns the character's nationality.
-- @treturn string The nationality.
--
function Character:getNationality()
    return self.nationality
end

---
-- Returns the character's size based on his stance.
-- @treturn number The character's size.
--
function Character:getHeight()
    return self.body:getHeight( self.stance )
end

---
-- Returns the character's current stance.
-- @treturn number The character's stance.
--
function Character:getStance()
    return self.stance
end

---
-- Gets the character's throwing skill.
-- @treturn number The character's throwing skill.
--
function Character:getThrowingSkill()
    return self.throwingSkill
end

---
-- Returns the total amount of action points.
-- @treturn number The total amount of action points.
--
function Character:getMaximumAP()
    return self.maximumAP
end

---
-- Returns the view range.
-- @treturn number The view range.
--
function Character:getViewRange()
    return self.viewRange
end

---
-- Checks if the character has an action enqueued.
-- @treturn boolean Wether an action is enqueued.
--
function Character:hasEnqueuedAction()
    return self.actions:getSize() > 0
end

---
-- Returns wether the character is dead or not.
-- @treturn boolean Wether the character is dead or not.
--
function Character:isDead()
    return self.body:getStatusEffects():isDead()
end

---
-- Gets an item of type weapon.
-- @treturn Weapon The weapon item.
--
function Character:getWeapon()
    return self:getEquipment():getItem( ITEM_TYPES.WEAPON )
end

---
-- Gets wether the character has finished a turn or not.
-- @treturn boolean Wether the character has finished a turn or not.
--
function Character:hasFinishedTurn()
    return self.finishedTurn
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the character's action points.
-- @tparam number ap The amount of AP to set.
--
    function Character:setCurrentAP( ap )
    self.currentAP = ap
end

---
-- Sets the character's new body.
-- @tparam Body body The body object to use.
--
function Character:setBody( body )
    self.body = body
    self.body:observe( self )
end

----
-- Sets the faction this character belongs to.
-- @tparam Faction faction The Faction object determining the character's faction.
--
function Character:setFaction( faction )
    self.faction = faction
end

---
-- Sets the mission counter.
-- @tparam number missions The new value for the mission counter.
--
function Character:setMissionCount( missions )
    self.missions = missions
end

---
-- Sets a new name for this character.
-- @tparam string name The name to set for this character.
--
function Character:setName( name )
    self.name = name
end

---
-- Sets the character's nationality.
-- @tparam string nationality The character's nationality.
--
function Character:setNationality( nationality )
    self.nationality = nationality
end

---
-- Sets if the character is done with a turn. This is used by the AI handler
-- to determine if the character is viable for another update.
-- @tparam boolean finished Wether the character is done with its turn.
--
function Character:setFinishedTurn( finished )
    self.finishedTurn = finished
end

---
-- Sets the character's stance.
-- @tparam number stance The character's new stance.
--
function Character:setStance( stance )
    self.stance = stance
end

return Character
