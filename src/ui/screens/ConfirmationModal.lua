---
-- This screen can be used to ask the user simple yes or no questions and
-- perform appropriate actions based on their choice.
-- @module ConfirmationModal
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' );
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIHorizontalList = require( 'src.ui.elements.lists.UIHorizontalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ConfirmationModal = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 10

local BUTTON_LIST_WIDTH = 20

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ConfirmationModal.new()
    local self = Screen.new()

    local background
    local outlines
    local x, y
    local tw, th

    local buttonList

    local text
    local trueCallback
    local falseCallback

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

    ---
    -- Creates the yes and no button at the bottom of the screen.
    --
    local function createButtons()
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = y + UI_GRID_HEIGHT - 2

        buttonList = UIHorizontalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        local buttonWidth = math.floor( BUTTON_LIST_WIDTH * 0.5 )

        local yesButton = UIButton( lx, ly, 0, 0, buttonWidth, 1, trueCallback, Translator.getText( 'ui_yes' ))
        buttonList:addChild( yesButton )

        local noButton = UIButton( lx, ly, 0, 0, buttonWidth, 1, falseCallback, Translator.getText( 'ui_no' ))
        buttonList:addChild( noButton )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the ConfirmationModal.
    -- @tparam string   ntext          The text to display inside of the modal.
    -- @tparam function ntrueCallback  The function to call when the yes button is clicked.
    -- @tparam function nfalseCallback The function to call when the no button is clicked.
    --
    function self:init( ntext, ntrueCallback, nfalseCallback )
        text = ntext
        trueCallback = ntrueCallback
        falseCallback = nfalseCallback

        tw, th = TexturePacks.getTileDimensions()
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()
        createButtons()
    end

    ---
    -- Draws the ConfirmationModal.
    --
    function self:draw()
        background:draw()
        outlines:draw()
        buttonList:draw()

        TexturePacks.setColor( 'ui_text' )
        love.graphics.printf( text, (x+2) * tw, (y+2) * th, (UI_GRID_WIDTH-4) * tw, 'center' )
        TexturePacks.resetColor()
    end

    ---
    -- Updates the ConfirmationModal.
    --
    function self:update()
        buttonList:update()
    end

    ---
    -- Handle keypressed events.
    --
    function self:keypressed( key, scancode )
        if key == 'escape' then
            falseCallback()
        end

        if scancode == 'left' then
            buttonList:command( 'left' )
        elseif scancode == 'right' then
            buttonList:command( 'right' )
        elseif scancode == 'return' then
            buttonList:command( 'activate' )
        end
    end

    ---
    -- Handle mousereleased events.
    --
    function self:mousereleased()
        buttonList:command( 'activate' )
    end

    return self
end

return ConfirmationModal
