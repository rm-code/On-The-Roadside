---
-- @module ChangelogScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIScrollArea = require( 'src.ui.elements.UIScrollArea' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UITextButton = require( 'src.ui.elements.UITextButton' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ChangelogScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FILE = 'CHANGELOG.md'
local SECTION_PREFIXES = {
    VERSION = '# Version ',
    ADDITIONS = '## Additions',
    REMOVALS = '## Removals',
    FIXES = '## Fixes',
    OTHER = '## Other Changes'
}

local SECTION_IDS = {
    ADDITIONS = 'additions',
    REMOVALS = 'removals',
    FIXES = 'fixes',
    OTHER = 'other'
}

local SECTION_HEADERS = {
    ADDITIONS = {
        COLOR = 'ui_changelog_additions',
        TEXT  = 'Additions'
    },
    REMOVALS = {
        COLOR = 'ui_changelog_removals',
        TEXT  = 'Removals'
    },
    FIXES = {
        COLOR = 'ui_changelog_fixes',
        TEXT  = 'Fixes'
    },
    OTHER = {
        COLOR = 'ui_changelog_other',
        TEXT  = 'Other Changes'
    }
}

local SCROLLAREA_GRID_WIDTH  = 56
local SCROLLAREA_GRID_HEIGHT = 42

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ChangelogScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local content
    local text
    local textHeight

    local buttonList
    local font
    local footer

    local scrollarea

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Checks if a line starts with a certain string.
    -- @tparam string  line   The line to search through.
    -- @tparam string  search The string to search for.
    -- @tparam boolean        Returns true if the line starts with the string.
    --
    local function startsWith( line, search )
        return string.find( line:upper(), search:upper() ) == 1
    end

    ---
    -- Parses the changelog file and breaks it down into its sections.
    --
    local function parseFile()
        content = {}

        local version
        local section
        local str = love.filesystem.read( LOG_FILE )
        for line in str:gmatch("[^\r\n]+") do
            if startsWith( line, SECTION_PREFIXES.VERSION ) then
                version = line:gsub( SECTION_PREFIXES.VERSION, '' )
                content[#content + 1] = { version = version }
            elseif startsWith( line, SECTION_PREFIXES.ADDITIONS ) then
                section = SECTION_IDS.ADDITIONS
                content[#content][section] = {}
            elseif startsWith( line, SECTION_PREFIXES.REMOVALS ) then
                section = SECTION_IDS.REMOVALS
                content[#content][section] = {}
            elseif startsWith( line, SECTION_PREFIXES.FIXES ) then
                section = SECTION_IDS.FIXES
                content[#content][section] = {}
            elseif startsWith( line, SECTION_PREFIXES.OTHER ) then
                section = SECTION_IDS.OTHER
                content[#content][section] = {}
            elseif content[#content][section] then
                local prefix, cline = string.match(line, '( *)%- (.*)')
                table.insert( content[#content][section], { text = cline, offset = math.floor( #prefix / 4 ) + 1 })
            end
        end
    end

    ---
    -- Creates a header for each version in the changelog.
    -- @tparam string version The version string to use as a header.
    -- @tparam number height  The current height of the text object.
    --
    local function createVersionHeader( version, height )
        local tw, _ = TexturePacks.getTileDimensions()
        height = height + text:getHeight()
        height = height + text:getHeight()
        text:addf({ TexturePacks.getColor( 'ui_changelog_version' ), version }, (SCROLLAREA_GRID_WIDTH - 1) * tw, 'left', 0, height )
        height = height + text:getHeight()
        local underline = version:gsub( '.', '_' )
        text:addf({ TexturePacks.getColor( 'ui_changelog_version' ), underline }, (SCROLLAREA_GRID_WIDTH - 1) * tw, 'left', 0, height )
        height = height + text:getHeight()
        height = height + text:getHeight()
        return height
    end

    ---
    -- Creates a section.
    -- @tparam string id     The type of section to create.
    -- @tparam table  log    A table containing the changelog information for a version.
    -- @tparam number height The current height of the Text object.
    --
    local function createSection( id, log, height )
        if not log[id] then
            return height
        end

        local tw, _ = TexturePacks.getTileDimensions()

        text:addf( { TexturePacks.getColor( SECTION_HEADERS[id:upper()].COLOR ), SECTION_HEADERS[id:upper()].TEXT }, (SCROLLAREA_GRID_WIDTH - 1) * tw, 'left', 0, height )
        height = height + text:getHeight()

        for _, line in ipairs( log[id] ) do
            text:addf({ TexturePacks.getColor( 'ui_changelog_text' ), '- ' },      (SCROLLAREA_GRID_WIDTH - 2 - line.offset) * tw, 'left', line.offset * tw, height )
            text:addf({ TexturePacks.getColor( 'ui_changelog_text' ), line.text }, (SCROLLAREA_GRID_WIDTH - 2 - line.offset) * tw, 'left', (1 + line.offset) * tw, height )
            height = height + text:getHeight()
        end

        return height + text:getHeight()
    end

    ---
    -- Creates the text object containing the changelog.
    --
    local function createLog()
        text = love.graphics.newText( font:get() )

        local height = 0
        for _, log in ipairs( content ) do
            height = createVersionHeader( log.version, height )

            height = createSection( SECTION_IDS.ADDITIONS, log, height )
            height = createSection( SECTION_IDS.REMOVALS,  log, height )
            height = createSection( SECTION_IDS.FIXES,     log, height )
            height = createSection( SECTION_IDS.OTHER,     log, height )
        end

        textHeight = height
    end

    ---
    -- Creates the back button at the bottom of the screen.
    --
    local function createButtons()
        local lx, ly = GridHelper.centerElement( SCROLLAREA_GRID_WIDTH, SCROLLAREA_GRID_HEIGHT )
        buttonList = UIVerticalList.new( lx, ly + SCROLLAREA_GRID_HEIGHT + 2, 0, 0, SCROLLAREA_GRID_WIDTH, SCROLLAREA_GRID_HEIGHT )

        local closeButton = UITextButton.new( lx, ly + SCROLLAREA_GRID_HEIGHT, 0, 0, SCROLLAREA_GRID_WIDTH, 1 )
        closeButton:init( Translator.getText( 'ui_back' ), function() ScreenManager.switch( 'mainmenu' ) end )
        buttonList:addChild( closeButton )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        font = TexturePacks.getFont()

        parseFile()
        createLog()

        createButtons()

        local ox, oy = GridHelper.centerElement( SCROLLAREA_GRID_WIDTH, SCROLLAREA_GRID_HEIGHT )
        scrollarea = UIScrollArea.new( ox, oy, 0, 0, SCROLLAREA_GRID_WIDTH, SCROLLAREA_GRID_HEIGHT )
        scrollarea:init( text, textHeight )

        footer = UICopyrightFooter.new()
    end

    function self:update()
        font = TexturePacks.getFont()
        buttonList:update()
    end

    function self:draw()
        font:use()
        scrollarea:draw()
        buttonList:draw()
        footer:draw()
    end

    function self:keypressed( key, scancode )
        if scancode == 'escape' then
            ScreenManager.switch( 'mainmenu' )
        end
        buttonList:keypressed( key, scancode )
    end

    function self:mousepressed( _, _ )
        local gx, gy = GridHelper.getMouseGridPosition()
        if scrollarea:isMouseOver() then
            scrollarea:mousepressed( gx, gy )
        end
    end

    function self:wheelmoved( _, dy )
        scrollarea:scroll( dy )
    end

    function self:mousereleased()
        buttonList:mousereleased()
    end

    function self:mousemoved()
        buttonList:mousemoved()
    end

    function self:resize( _, _ )
        local lx, ly = GridHelper.centerElement( SCROLLAREA_GRID_WIDTH, SCROLLAREA_GRID_HEIGHT )
        buttonList:setOrigin( lx, ly + SCROLLAREA_GRID_HEIGHT )
        scrollarea:setOrigin( lx, ly )
    end

    return self
end

return ChangelogScreen