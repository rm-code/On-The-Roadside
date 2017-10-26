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
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CharacterSelector = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function CharacterSelector.new()
    local self = Observable.new():addInstance( 'CharacterSelector' )

    local faction
    local verticalList
    local header
    local font

    local background
    local outlines
    local tw, th
    local x, y

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Generates the outlines for this screen.
    --
    local function generateOutlines( w, h )
        outlines = UIOutlines.new( x, y, 0, 0, w, h )

        -- Horizontal borders.
        for ox = 0, w-1 do
            outlines:add( ox, 0   ) -- Top
            outlines:add( ox, 2   ) -- Top
            outlines:add( ox, h-1 ) -- Bottom
        end

        -- Vertical outlines.
        for oy = 0, h-1 do
            outlines:add( 0,   oy ) -- Left
            outlines:add( w-1, oy ) -- Right
        end

        outlines:refresh()
    end

    local function createCharacterButton( character )
        local function callback()
            self:publish( 'CHANGED_CHARACTER', character )
        end
        return Button.new( character:getName(), callback, 'left' )
    end

    local function createCharacterList()
        verticalList = VerticalList.new( tw, 3 * th, (UI_GRID_WIDTH-2) * tw, font:getGlyphHeight() )
        faction:iterate( function( character )
            verticalList:addElement( createCharacterButton( character ))
        end)
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nfaction )
        faction = nfaction
        font = TexturePacks.getFont()

        x, y = 0, 0
        tw, th = TexturePacks.getTileset():getTileDimensions()

        createCharacterList()

        background = UIBackground.new( x, y, 0, 0, UI_GRID_WIDTH, 4 + verticalList:getElementCount() )

        generateOutlines( UI_GRID_WIDTH, 4 + verticalList:getElementCount() )

        header = Label.new( Translator.getText( 'ui_stalkers' ), 'ui_label', 'center' )
    end

    function self:draw()
        background:draw()
        outlines:draw()
        header:draw( tw, th, (UI_GRID_WIDTH-2) * tw, 'center' )
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
