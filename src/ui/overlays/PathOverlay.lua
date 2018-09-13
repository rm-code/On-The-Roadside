---
-- The PathOverlay module draws the movement path of the currently selected
-- character.
-- @module PathOverlay
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local MovementInput = require( 'src.turnbased.helpers.MovementInput' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PathOverlay = Class( 'PathOverlay' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Selects a color for the node in a path based on the distance to the
-- target and the remaining action points the character has.
-- @param value (number) The cost of the node.
-- @param total (number) The total number of nodes in the path.
--
local function selectPathNodeColor( value, total )
    local fraction = value / total
    if fraction < 0 then
        return TexturePacks.getColor( 'ui_path_ap_low' )
    elseif fraction <= 0.2 then
        return TexturePacks.getColor( 'ui_path_ap_med' )
    elseif fraction <= 0.6 then
        return TexturePacks.getColor( 'ui_path_ap_high' )
    elseif fraction <= 1.0 then
        return TexturePacks.getColor( 'ui_path_ap_full' )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes the PathOverlay object.
-- @tparam Game   game   The game object.
-- @tparam Pulser pulser The pulser used for animating the overlay.
--
function PathOverlay:initialize( game, pulser )
    self.game = game
    self.pulser = pulser
end

---
-- Draws a path for this character.
--
function PathOverlay:draw()
    local tw, th = TexturePacks.getTileDimensions()
    local character = self.game:getCurrentCharacter()
    local mode = self.game:getState():getInputMode()
    if mode:isInstanceOf( MovementInput ) and mode:hasPath() then
        local total = character:getCurrentAP()
        local ap = total
        mode:getPath():iterate( function( tile )
            ap = ap - tile:getMovementCost( character:getStance() )

            -- Draws the path overlay.
            love.graphics.setBlendMode( 'add' )
            local color = selectPathNodeColor( ap, total )
            love.graphics.setColor( color[1], color[2], color[3], self.pulser:getPulse() )
            love.graphics.rectangle( 'fill', tile:getX() * tw, tile:getY() * th, tw, th )
            TexturePacks.resetColor()
            love.graphics.setBlendMode( 'alpha' )
        end)
    end
end

return PathOverlay
