---
-- The PathOverlay module draws the movement path of the currently selected
-- character.
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PathOverlay = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PathOverlay.new( game, pulser )
    local self = Object.new():addInstance( 'PathOverlay' )

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
    -- Draws a path for this character.
    --
    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        local character = game:getCurrentCharacter()
        local mode = game:getState():getInputMode()
        if mode:instanceOf( 'MovementInput' ) and mode:hasPath() then
            local total = character:getActionPoints()
            local ap = total
            mode:getPath():iterate( function( tile )
                ap = ap - tile:getMovementCost( character:getStance() )

                -- Draws the path overlay.
                love.graphics.setBlendMode( 'add' )
                local color = selectPathNodeColor( ap, total )
                love.graphics.setColor( color[1], color[2], color[3], pulser:getPulse() )
                love.graphics.rectangle( 'fill', tile:getX() * tw, tile:getY() * th, tw, th )
                TexturePacks.resetColor()
                love.graphics.setBlendMode( 'alpha' )
            end)
        end
    end

    return self
end

return PathOverlay
