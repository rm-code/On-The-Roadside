---
-- @module HealthScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HealthScreen = Screen:subclass( 'HealthScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 30
local UI_GRID_HEIGHT = 16

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Generates the outlines for this screen.
-- @tparam  number     x The origin of the screen along the x-axis.
-- @tparam  number     y The origin of the screen along the y-axis.
-- @treturn UIOutlines   The newly created UIOutlines instance.
--
local function generateOutlines( x, y )
    local outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    -- Horizontal borders.
    for ox = 0, UI_GRID_WIDTH-1 do
        outlines:add( ox, 0                ) -- Top
        outlines:add( ox, 2                ) -- Header
        outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
    end

    -- Vertical outlines.
    for oy = 0, UI_GRID_HEIGHT-1 do
        outlines:add( 0,               oy ) -- Left
        outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
    end

    outlines:refresh()
    return outlines
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function HealthScreen:initialize( character )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.character = character
    self.characterType = character:getBody():getID()

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
end

function HealthScreen:draw()
    self.background:draw()
    self.outlines:draw()

    local tw, th = TexturePacks.getTileDimensions()
    local counter = 3
    for _, bodyPart in pairs( self.character:getBody():getBodyParts() ) do
        if bodyPart:isEntryNode() then
            counter = counter + 1
            local status
            if bodyPart:isDestroyed() then
                TexturePacks.setColor( 'ui_health_destroyed_limb' )
                status = 'DED'
            elseif bodyPart:getCurrentHealth() / bodyPart:getMaximumHealth() < 0.2 then
                TexturePacks.setColor( 'ui_health_badly_damaged_limb' )
                status = 'OUCH'
            elseif bodyPart:getCurrentHealth() / bodyPart:getMaximumHealth() < 0.4 then
                TexturePacks.setColor( 'ui_health_damaged_limb' )
                status = 'MEH'
            elseif bodyPart:getCurrentHealth() / bodyPart:getMaximumHealth() < 0.7 then
                TexturePacks.setColor( 'ui_health_ok_limb' )
                status = 'OK'
            else
                TexturePacks.setColor( 'ui_health_fine_limb' )
                status = 'FINE'
            end
            love.graphics.print( Translator.getText( bodyPart:getID() ), (self.x+1) * tw, (self.y+counter) * th )
            love.graphics.printf( status, (self.x+1) * tw, (self.y+counter) * th, ( UI_GRID_WIDTH - 2 ) * tw, 'right' )

            if bodyPart:isBleeding() then
                local str = string.format( 'Bleeding %1.2f', bodyPart:getBloodLoss() )
                if bodyPart:getBloodLoss() / 1.0 < 0.2 then
                    TexturePacks.setColor( 'ui_health_bleeding_fine' )
                elseif bodyPart:getBloodLoss() / 1.0 < 0.4 then
                    TexturePacks.setColor( 'ui_health_bleeding_ok' )
                elseif bodyPart:getCurrentHealth() / bodyPart:getMaximumHealth() < 0.7 then
                    TexturePacks.setColor( 'ui_health_bleeding' )
                elseif bodyPart:getCurrentHealth() / bodyPart:getMaximumHealth() < 1.0 then
                    TexturePacks.setColor( 'ui_health_bleeding_bad' )
                end
                love.graphics.printf( str, (self.x+1) * tw, (self.y+counter) * th, ( UI_GRID_WIDTH - 2 ) * tw, 'center' )
            end
        end
    end

    TexturePacks.setColor( 'ui_text' )

    -- Draw character type.
    local type = Translator.getText( 'ui_character_type' ) .. Translator.getText( self.characterType )
    love.graphics.print( type, (self.x+1) * tw, (self.y+1) * th )

    -- Draw character name.
    if self.character:getName() then
        local name = Translator.getText( 'ui_character_name' ) .. self.character:getName()
        love.graphics.print( name, (self.x+2) * tw + TexturePacks.getFont():measureWidth( type ), (self.y+1) * th )
    end

    TexturePacks.resetColor()
end

function HealthScreen:keypressed( key )
    if key == 'escape' or key == 'h' then
        ScreenManager.pop()
    end
end

return HealthScreen
