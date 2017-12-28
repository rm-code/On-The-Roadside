---
-- @module Path
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Walk = require( 'src.characters.actions.Walk' )
local Open = require( 'src.characters.actions.Open' )
local OpenInventory = require( 'src.characters.actions.OpenInventory' )
local ClimbOver = require( 'src.characters.actions.ClimbOver' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Path = Class( 'Path' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Generate smart actions for openable objects. These are a special case,
-- because usually the player will want to move a character onto the tile
-- after the object is openend.
-- @tparam WorldObject worldObject The worldobject to interact with.
-- @tparam Character   character   The character that interacts with the object.
-- @tparam Tile        tile        The tile containing the worldobject.
-- @tparam number      index       The tile's position in the path.
--
local function handleOpenableObjects( worldObject, character, tile, index )
    if not worldObject:isPassable() then
        local success = character:enqueueAction( Open( character, tile ))
        -- Don't create a walk action if the tile is the last one in the path.
        if success and index ~= 1 then
            success = character:enqueueAction( Walk( character, tile ))
        end
        return success
    end
    return character:enqueueAction( Walk( character, tile ))
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new Path object.
--
function Path:initialize()
    self.path = {}
    self.cost = 0
end

---
-- Iterates over the path. The target tile will be processed at last.
-- @tparam function callback A function to call on every tile.
--
function Path:iterate( callback )
    for i = #self.path, 1, -1 do
        callback( self.path[i], i )
    end
end

---
-- Adds a new tile to this path.
-- @tparam Tile   tile A tile to add to this path.
-- @tparam number cost The cost to traverse this tile.
--
function Path:addNode( tile, cost )
    self.path[#self.path + 1] = tile
    self.cost = self.cost + cost
end

---
-- Automagically generates appropriate Actions for each tile in the path.
-- For example if the character moves through a tile with a door object this
-- function will generate an action to open the door and an action to walk
-- onto the tile itself.
-- @tparam  Character character The character to create the actions for.
-- @treturn boolean             Wether actions have been created or not.
--
function Path:generateActions( character )
    local generatedAction = false
    for index = #self.path, 1, -1 do
        local tile = self.path[index]
        local success

        if tile:hasWorldObject() then
            local worldObject = tile:getWorldObject()

            if worldObject:isOpenable() then
                success = handleOpenableObjects( worldObject, character, tile, index )
            end

            if worldObject:isClimbable() then
                success = character:enqueueAction( ClimbOver( character, tile ))
            end

            if worldObject:isContainer() then
                character:enqueueAction( OpenInventory( character, tile ))
            end
        else
            success = character:enqueueAction( Walk( character, tile ))
        end

        -- Stop adding actions if the previous one wasn't added correctly.
        if not success then
            break
        else
            generatedAction = true
        end
    end
    return generatedAction
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the length of the path.
-- @treturn number The length of the path.
--
function Path:getLength()
    return #self.path
end

---
-- Returns the target tile of the path.
-- @treturn Tile The target of the path.
--
function Path:getTarget()
    return self.path[1]
end

---
-- Returns the cost for the path.
-- @treturn number The cost.
--
function Path:getCost()
    return self.cost
end

return Path
