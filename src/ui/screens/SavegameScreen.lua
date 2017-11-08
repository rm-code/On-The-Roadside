---
-- @module SavegameScreen
--

local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local SaveHandler = require( 'src.SaveHandler' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UITextButton = require( 'src.ui.elements.UITextButton' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SavegameScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local TITLE_STRING = {
    " @@@@@     @@@@@@   @@@  @@@  @@@@@@@    @@@@@  ",
    "@@@@@@@   @@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@ ",
    "!@@       @@!  @@@  @@!  @@@  @@!       !@@     ",
    "!@!       !@!  @!@  !@!  @!@  !@!       !@!     ",
    "!!@@!!    @!@!@!@!  @!@  !@!  @!!!:!    !!@@!!  ",
    " !!@!!!   !!!@!!!!  !@!  !!!  !!!!!:     !!@!!! ",
    "     !:!  !!:  !!!  :!:  !!:  !!:            !:!",
    "    !:!   :!:  !:!   ::!!::   :!:           !:! ",
    "::!::::    ::   ::    !:::    ::!::!!   ::!:::: ",
    " :::..      !    :     !:     :!:::::!   :::..  "
}

local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SavegameScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title
    local buttonList
    local font
    local footer

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTitle()
        title = love.graphics.newText( font:get() )
        for i, line in ipairs( TITLE_STRING ) do
            local coloredtext = {}
            for w in string.gmatch( line, '.' ) do
                if w == '@' then
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_1' )
                    coloredtext[#coloredtext + 1] = 'O'
                elseif w == '!' then
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_2' )
                    coloredtext[#coloredtext + 1] = w
                else
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_3' )
                    coloredtext[#coloredtext + 1] = w
                end
                title:add( coloredtext, 0, i * font:get():getHeight() )
            end
        end
    end

    local function drawTitle()
        local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
        local tw, _ = TexturePacks.getTileDimensions()
        love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
    end

    local function createBackButton( lx, ly, index )
        local function callback()
            ScreenManager.switch( 'mainmenu' )
        end
        local button = UITextButton.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        button:init( Translator.getText( 'ui_back' ), callback )
        return button
    end

    local function createSaveGameEntry( lx, ly, index, item, folder )
        local version = SaveHandler.loadVersion( folder )

        local str = string.format( '%2d. %s (Version: %s)', index, os.date( '%d.%m.%Y - %X', item ), version )
        local function callback()
            if version == getVersion() then
                local save = SaveHandler.load( folder )
                ScreenManager.switch( 'gamescreen', save )
            end
        end

        local button = UITextButton.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        button:init( str, callback )
        button:setActive( version == getVersion() )
        return button
    end


    local function createButtons()
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y

        buttonList = UIVerticalList.new( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        -- Create entries for last five savegames.
        local items = love.filesystem.getDirectoryItems( SaveHandler.getSaveFolder() )
        local counter = 0

        for i = #items, 1, -1 do
            local item = items[i]
            if love.filesystem.isDirectory( SaveHandler.getSaveFolder() .. '/' .. item ) then
                counter = counter + 1
                buttonList:addChild( createSaveGameEntry( lx, ly, counter, item, SaveHandler.getSaveFolder() .. '/' .. item ))
            end
        end

        buttonList:addChild( createBackButton( lx, ly, counter+2 ))
    end


    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        font = TexturePacks.getFont()

        createTitle()
        createButtons()

        footer = UICopyrightFooter.new()
    end

    function self:update()
        font = TexturePacks.getFont()
        buttonList:update()
    end

    function self:draw()
        font:use()
        drawTitle()
        buttonList:draw()

        footer:draw()
    end

    function self:keypressed( key, scancode )
        if scancode == 'escape' then
            ScreenManager.switch( 'mainmenu' )
        end
        buttonList:keypressed( key, scancode )
    end

    function self:mousereleased()
        buttonList:mousereleased()
    end

    function self:mousemoved()
        buttonList:mousemoved()
    end

    function self:resize( _, _ )
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y
        buttonList:setOrigin( lx, ly )
    end

    return self
end

return SavegameScreen
