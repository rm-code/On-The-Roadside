---
-- The PathOverlay module draws the movement path of the currently selected
-- character.
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PathOverlay = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS    = require( 'src.constants.Colors' )
local TILE_SIZE = require( 'src.constants.TileSize' )

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
            return COLORS.DB27
        elseif fraction <= 0.2 then
            return COLORS.DB05
        elseif fraction <= 0.6 then
            return COLORS.DB08
        elseif fraction <= 1.0 then
            return COLORS.DB09
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Draws a path for this character.
    --
    function self:draw()
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
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE )
                love.graphics.setColor( COLORS.RESET )
                love.graphics.setBlendMode( 'alpha' )
            end)
        end
    end

    return self
end

return PathOverlay
