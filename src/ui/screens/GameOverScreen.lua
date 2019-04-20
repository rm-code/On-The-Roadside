---
-- @module GameOverScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local DataHandler = require( 'src.DataHandler' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameOverScreen = Screen:subclass( 'GameOverScreen' )

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

function GameOverScreen:initialize(  playerFaction, win )
    self.playerFaction = playerFaction
    self.win = win

    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )

    self.text = self.win and Translator.getText( 'ui_win' ) or Translator.getText( 'ui_lose' )
end

function GameOverScreen:draw()
    self.background:draw()
    self.outlines:draw()

    local tw, th = TexturePacks.getTileDimensions()
    love.graphics.printf( self.text, self.x * tw, (self.y+6) * th, UI_GRID_WIDTH * tw, 'center' )
end

function GameOverScreen:keypressed()
    if self.win then
        self.playerFaction:iterate( function( character )
            character:incrementMissionCount()
        end)

        DataHandler.copyPlayerFaction( self.playerFaction:serialize() )
        ScreenManager.switch( 'base' )
        return
    end
    ScreenManager.switch( 'mainmenu' )
end

return GameOverScreen
