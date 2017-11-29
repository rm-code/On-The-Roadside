---
-- The parent class for all Actions
-- @module Action
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Action = Class( 'Action' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new instance of the Action class.
-- @tparam Character character The character performing the action.
-- @tparam number    cost      The number of AP it takes to perform this action.
-- @tparam Tile      target    The target tile to perform this action on.
--
function Action:initialize( character, target, cost )
    self.character = character
    self.cost = cost
    self.target = target
end

---
-- Returns the character performing the Action.
-- @treturn number The action's AP cost.
--
function Action:getCharacter()
    return self.character
end

---
-- Returns the cost it takes to perform this Action.
-- @treturn number The action's AP cost.
--
function Action:getCost()
    return self.cost
end

---
-- Returns the target tile on which to perform the Action.
-- @treturn Tile The target tile for this Action.
--
function Action:getTarget()
    return self.target
end

return Action
