---
-- @module HealAllSelector
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
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HealAllSelector = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SCREEN_WIDTH  = 10
local SCREEN_HEIGHT =  3
local FIELD_WIDTH   = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function HealAllSelector.new()
    local self = Observable.new():addInstance( 'HealAllSelector' )

    local verticalList
    local font
    local outlines
    local tw, th
    local px, py

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
            self:publish( 'HEAL_CHARACTERS' )
        end
        return Button.new( Translator.getText( 'ui_heal_all' ), callback )
    end

    function self:init()
        local sw, sh = GridHelper.getScreenGridDimensions()
        px, py = sw - FIELD_WIDTH, sh - SCREEN_HEIGHT

        font = TexturePacks.getFont()
        tw, th = TexturePacks.getTileset():getTileDimensions()

        verticalList = VerticalList.new( px*tw, (py+1)*th, FIELD_WIDTH * tw, font:getGlyphHeight() )
        verticalList:addElement( createButton() )

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', px*tw, py*th, FIELD_WIDTH * tw, SCREEN_HEIGHT * th )
        TexturePacks.resetColor()

        outlines:draw( px*tw, py*th )
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

return HealAllSelector
