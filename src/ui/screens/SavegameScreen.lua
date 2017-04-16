---
-- @module SavegameScreen
--

local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local VerticalList = require( 'src.ui.elements.VerticalList' )
local Button = require( 'src.ui.elements.Button' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local SaveHandler = require( 'src.SaveHandler' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SavegameScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FIELD_WIDTH = 300

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

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SavegameScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title
    local verticalList
    local font

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

    local function createBackButton()
        local function callback()
            ScreenManager.switch( 'mainmenu' )
        end
        return Button.new( Translator.getText( 'ui_back' ), callback )
    end

    local function createSaveGameEntry( index, item, folder )
        local version = SaveHandler.loadVersion( folder )

        local str
        if version == getVersion() then
            str = os.date( index .. '. ' .. "%d.%m.%Y - %X", item )
        else
            str = Translator.getText( 'ui_invalid_save_version' )
        end

        local function callback()
            if version == getVersion() then
                local save = SaveHandler.load( folder )
                ScreenManager.switch( 'combat', save )
            end
        end

        return Button.new( str, callback )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        font = TexturePacks.getFont()

        createTitle()

        local x = love.graphics.getWidth() * 0.5 - FIELD_WIDTH * 0.5
        local y = 20 * font:getGlyphHeight()

        verticalList = VerticalList.new( x, y, FIELD_WIDTH, font:getGlyphHeight() )

        -- Create entries for last five savegames.
        local items = love.filesystem.getDirectoryItems( SaveHandler.getSaveFolder() )
        local counter = 0
        for i = #items, 1, -1 do
            local item = items[i]
            if love.filesystem.isDirectory( SaveHandler.getSaveFolder() .. '/' .. item ) then
                counter = counter + 1
                verticalList:addElement( createSaveGameEntry( counter, item, SaveHandler.getSaveFolder() .. '/' .. item ))
            end
        end

        verticalList:addElement( createBackButton() )
    end

    function self:update()
        font = TexturePacks.getFont()
        verticalList:update()
    end

    function self:draw()
        font:use()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, TITLE_POSITION * font:getGlyphHeight() )
        verticalList:draw()
    end

    function self:keypressed( key, scancode )
        if scancode == 'escape' then
            ScreenManager.switch( 'mainmenu' )
        end
        verticalList:keypressed( key, scancode )
    end

    function self:mousereleased()
        verticalList:mousereleased()
    end

    function self:mousemoved()
        verticalList:mousemoved()
    end

    function self:resize( nw, _ )
        local x = nw * 0.5 - FIELD_WIDTH * 0.5
        local y = 20 * font:getGlyphHeight()
        verticalList:setPosition( x, y )
    end

    return self
end

return SavegameScreen
