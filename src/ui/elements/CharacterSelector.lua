---
-- @module CharacterSelector
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local VerticalList = require( 'src.ui.elements.VerticalList' )
local Button = require( 'src.ui.elements.Button' )
local Label = require( 'src.ui.elements.Label' )
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

    local faction
    local verticalList
    local header
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
        return Button.new( character:getName(), callback, 'left' )
    end

    function self:init( nfaction )
        faction = nfaction
        font = TexturePacks.getFont()

        tw, th = TexturePacks.getTileset():getTileDimensions()
        verticalList = VerticalList.new( tw, 3 * th, (FIELD_WIDTH-2) * tw, font:getGlyphHeight() )

        faction:iterate( function( character )
            verticalList:addElement( createCharacterButton( character ))
        end)

        outlines = Outlines.new( 0, 0 )
        createOutlines( SCREEN_WIDTH, 4 + verticalList:getElementCount() )
        outlines:refresh()

        header = Label.new( Translator.getText( 'ui_stalkers' ), 'ui_label', 'center' )
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', 0, 0, FIELD_WIDTH * tw, (4 + verticalList:getElementCount()) * th )
        TexturePacks.resetColor()

        header:draw( tw, th, (FIELD_WIDTH-2) * tw, 'center' )

        outlines:draw()
        verticalList:draw()
    end

    function self:update()
        verticalList:update()
    end

    function self:keypressed( _, scancode )
        -- Character selection.
        if scancode == 'space' then
            local character = faction:nextCharacter()
            self:publish( 'CHANGED_CHARACTER', character )
        elseif scancode == 'backspace' then
            local character = faction:prevCharacter()
            self:publish( 'CHANGED_CHARACTER', character )
        end

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

return CharacterSelector
