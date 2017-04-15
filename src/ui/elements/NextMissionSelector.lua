---
-- @module NextMissionSelector
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local VerticalList = require( 'src.ui.elements.VerticalList' )
local Button = require( 'src.ui.elements.Button' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Outlines = require( 'src.ui.elements.Outlines' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local NextMissionSelector = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SCREEN_WIDTH  = 10
local SCREEN_HEIGHT =  3
local FIELD_WIDTH   = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function NextMissionSelector.new()
    local self = Observable.new():addInstance( 'NextMissionSelector' )

    local verticalList
    local font
    local outlines
    local tw, th

    local function createOutlines( w, h )
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    outlines:add( x, y )
                end
            end
        end
    end

    local function createButton()
        local function callback()
            self:publish( 'LOAD_COMBAT_MISSION' )
        end
        return Button.new( Translator.getText( 'ui_next_mission' ), callback )
    end

    function self:init()
        font = TexturePacks.getFont()
        tw, th = TexturePacks.getTileset():getTileDimensions()

        verticalList = VerticalList.new( love.graphics.getWidth() - FIELD_WIDTH * tw, th, FIELD_WIDTH * tw, font:getGlyphHeight() )
        verticalList:addElement( createButton() )

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', love.graphics.getWidth() - FIELD_WIDTH * tw, 0, FIELD_WIDTH * tw, 3 * th )
        TexturePacks.resetColor()

        love.graphics.printf( Translator.getText( 'ui_stalkers' ), tw, th, (FIELD_WIDTH-2) * tw, 'center' )

        outlines:draw( love.graphics.getWidth() - FIELD_WIDTH * tw, 0 )
        verticalList:draw()
    end

    function self:update()
        verticalList:update()
    end

    function self:keypressed( _, scancode )
        verticalList:keypressed( _, scancode )
    end

    function self:mousemoved()
        verticalList:mousemoved()
    end

    function self:mousereleased()
        verticalList:mousereleased()
    end

    return self
end

return NextMissionSelector
