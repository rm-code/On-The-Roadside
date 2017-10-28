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
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local NextMissionSelector = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 10
local UI_GRID_HEIGHT =  3

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function NextMissionSelector.new()
    local self = Observable.new():addInstance( 'NextMissionSelector' )

    local verticalList
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
    local function generateOutlines()
        outlines = UIOutlines.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        -- Horizontal borders.
        for ox = 0, UI_GRID_WIDTH-1 do
            outlines:add( ox, 0                ) -- Top
            outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
        end

        -- Vertical outlines.
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 0,               oy ) -- Left
            outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
        end

        outlines:refresh()
    end

    local function createButton()
        local function callback()
            self:publish( 'LOAD_COMBAT_MISSION' )
        end
        return Button.new( Translator.getText( 'ui_next_mission' ), callback )
    end

    function self:init()
        local sw, _ = GridHelper.getScreenGridDimensions()
        x, y = sw - UI_GRID_WIDTH, 0

        font = TexturePacks.getFont()
        tw, th = TexturePacks.getTileset():getTileDimensions()

        verticalList = VerticalList.new( x * tw, (y+1) * th, UI_GRID_WIDTH * tw, font:getGlyphHeight() )
        verticalList:addElement( createButton() )

        background = UIBackground.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_WIDTH )
        generateOutlines()
    end

    function self:draw()
        background:draw()
        outlines:draw()
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
