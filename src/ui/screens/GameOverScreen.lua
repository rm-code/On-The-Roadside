---
-- @module GameOverScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameOverScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 30
local UI_GRID_HEIGHT = 16

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameOverScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local text
    local outlines
    local background
    local x, y
    local win
    local playerFaction

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Generates the outlines for this screen.
    --
    local function generateOutlines()
        outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

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

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nplayerFaction, nwin )
        playerFaction = nplayerFaction
        win = nwin

        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()

        text = win and Translator.getText( 'ui_win' ) or Translator.getText( 'ui_lose' )
    end

    function self:draw()
        background:draw()
        outlines:draw()

        local tw, th = TexturePacks.getTileDimensions()
        love.graphics.printf( text, x * tw, (y+6) * th, UI_GRID_WIDTH * tw, 'center' )
    end

    function self:keypressed()
        if win then
            ScreenManager.pop()
            ScreenManager.push( 'base', playerFaction )
        else
            ScreenManager.switch( 'mainmenu' )
        end
    end

    return self
end

return GameOverScreen
