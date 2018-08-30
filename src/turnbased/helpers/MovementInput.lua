---
-- @module MovementInput
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local PathFinder = require( 'src.characters.pathfinding.PathFinder' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MovementInput = Class( 'MovementInput' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function generatePath( target, character )
    if target and target:isPassable() and not target:hasCharacter() then
        return PathFinder.generatePath( character:getTile(), target, character:getStance() )
    end
end
-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a path to the target for the given character. The first time it will
-- generate a path, but don't generate any actions. This is used to preview the
-- path for the player. If there is a path and the target is the target of the
-- existing path the we generate all the actions needed to move the character.
-- @tparam  Tile      target    The tile to act upon.
-- @tparam  Character character The character to create the action for.
-- @treturn boolean             True if an action was created, false otherwise.
--
function MovementInput:request( target, character )
    -- Don't generate a path for the tile the character is standing on.
    if target == character:getTile() then
        return false
    end

    -- Generate a new path if we don't have one already or if the target is
    -- different from the target of an existing path.
    if not self.path or target ~= self.path:getTarget() then
        self.path = generatePath( target, character )
        return false
    end

    -- Generate actions for the existing path.
    self.path:generateActions( character )
    self.path = nil
    return true
end

---
-- Checks wether there is a generated path.
-- @treturn boolean True if a path exists.
--
function MovementInput:hasPath()
    return self.path ~= nil
end

---
-- Returns the generated path.
-- @treturn Path The generated path.
function MovementInput:getPath()
    return self.path
end

---
-- Returns the predicted ap cost for this action.
-- @treturn number The cost.
--
function MovementInput:getPredictedAPCost()
    return self.path:getCost()
end

return MovementInput
