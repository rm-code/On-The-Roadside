---
-- @module InputDialog
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InputDialog = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 6

local MAX_ENTRY_LENGTH = (UI_GRID_WIDTH - 4) * 2

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InputDialog.new()
    local self = Screen.new()

    local background
    local outlines
    local x, y
    local tw, th

    local text
    local entry

    local deleteAll

    local confirmCallback

    local timer
    local showCursor

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

    ---
    -- Initialises the ConfirmationModal.
    --
    function self:init( ntext, template, nconfirmCallback )
        timer = 0

        text = ntext
        entry = template or ''
        deleteAll = template and true

        confirmCallback = nconfirmCallback

        tw, th = TexturePacks.getTileDimensions()
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()
    end

    function self:update( dt )
        timer = timer + dt

        if timer > 0.5 then
            showCursor = not showCursor
            timer = 0
        end
    end

    ---
    -- Draws the ConfirmationModal.
    --
    function self:draw()
        background:draw()
        outlines:draw()

        -- Draw the instructions.
        TexturePacks.setColor( 'ui_text' )
        love.graphics.printf( text, (x+1) * tw, (y+1) * th, (UI_GRID_WIDTH-2) * tw, 'left' )

        -- Draw the entered text.
        TexturePacks.setColor( 'ui_text_dark' )
        love.graphics.printf( entry, (x+2) * tw, (y+3) * th, (UI_GRID_WIDTH-4) * tw, 'left' )

        if showCursor and #entry < MAX_ENTRY_LENGTH then
            TexturePacks.setColor( 'ui_text_dark' )
            love.graphics.print( '_', (x+2) * tw + TexturePacks.getFont():measureWidth( entry ), (y+3) * th )
        end

        TexturePacks.resetColor()
    end

    ---
    -- Handle keypressed events.
    --
    function self:keypressed( _, scancode )
        if scancode == 'escape' then
            ScreenManager.pop()
        elseif scancode == 'return' then
            confirmCallback( entry )
        end

        if scancode == 'backspace' then
            if deleteAll then
                entry = ''
            else
                entry = entry:sub( 1, #entry-1 )
            end
        end
    end

    ---
    -- Handle textinput events.
    --
    function self:textinput( character )
        local c = character:match( '[%w_]' )
        if c and #entry < MAX_ENTRY_LENGTH then
            entry = entry .. c
        end
    end

    return self
end

return InputDialog
