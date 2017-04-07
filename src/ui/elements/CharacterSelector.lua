---
-- @module CharacterSelector
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

local CharacterSelector = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SCREEN_WIDTH = 10
local FIELD_WIDTH  = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function CharacterSelector.new()
    local self = Observable.new():addInstance( 'CharacterSelector' )

    local playerFaction
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
                if y == 2 then
                    outlines:add( x, y )
                end
            end
        end
    end

    local function createCharacterButton( character )
        local function callback()
            self:publish( 'CHANGED_CHARACTER', character )
        end
        return Button.new( character:getName(), callback )
    end

    function self:init( nfactions )
        playerFaction = nfactions:getPlayerFaction()
        font = TexturePacks.getFont()

        tw, th = TexturePacks.getTileset():getTileDimensions()
        verticalList = VerticalList.new( 0, 3 * th, FIELD_WIDTH * tw, font:getGlyphHeight() )

        playerFaction:iterate( function( character )
            verticalList:addElement( createCharacterButton( character ))
        end)

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, 4 + verticalList:getElementCount() )
        outlines:refresh()
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', 0, 0, FIELD_WIDTH * tw, (4 + verticalList:getElementCount()) * th )
        TexturePacks.resetColor()

        love.graphics.printf( Translator.getText( 'ui_stalkers' ), tw, th, (FIELD_WIDTH-2) * tw, 'center' )

        outlines:draw( 0, 0 )
        verticalList:draw()
    end

    function self:update()
        verticalList:update()
    end

    function self:keypressed( _, scancode )
        verticalList:keypressed( _, scancode )
    end

    return self
end

return CharacterSelector
