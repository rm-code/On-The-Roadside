---
-- @module UISaveGameEntry
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Observable = require( 'src.util.Observable' )
local SaveHandler = require( 'src.SaveHandler' )

local UIElement = require( 'src.ui.elements.UIElement' )
local UIObservableButton = require( 'src.ui.elements.UIObservableButton' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UISaveGameEntry = UIElement:subclass( 'UISaveGameEntry' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 42
local UI_GRID_HEIGHT = 1

local LOADING_BUTTON_OFFSET_W = 16

local TYPE_LABEL_OFFSET_X = LOADING_BUTTON_OFFSET_W + 1
local TYPE_LABEL_WIDTH = 4

local VERSION_LABEL_OFFSET_X = TYPE_LABEL_WIDTH + TYPE_LABEL_OFFSET_X + 1
local VERSION_LABEL_WIDTH = 8

local DATE_LABEL_OFFSET_X = VERSION_LABEL_OFFSET_X + VERSION_LABEL_WIDTH
local DATE_LABEL_WIDTH = 10

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function determineVersionColor( valid )
    if not valid then
        return 'ui_invalid'
    end
    return 'ui_valid'
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UISaveGameEntry:initialize( ox, oy, rx, ry, name, version, date, type, valid )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.name = name
    self.valid = valid

    self.observable = Observable()

    self.loadButton = UIObservableButton( self.ax, self.ay, 0, 0, LOADING_BUTTON_OFFSET_W, 1, name, 'left', 'LOAD_SAVE' )
    self.loadButton:setActive( self.valid )
    self.loadButton:observe( self )

    self.deleteButton = UIObservableButton( self.ax, self.ay, UI_GRID_WIDTH - 1, 0, 1, 1, '', 'left', 'DELETE_SAVE' )
    self.deleteButton:setIcon( 'ui_delete' )
    self.deleteButton:observe( self )

    self.typeLabel = UILabel( self.ax, self.ay, TYPE_LABEL_OFFSET_X, 0, TYPE_LABEL_WIDTH, 1, type, 'ui_text_passive', 'left' )
    self.versionLabel = UILabel( self.ax, self.ay, VERSION_LABEL_OFFSET_X, 0, VERSION_LABEL_WIDTH, 1, version, determineVersionColor( valid ), 'left' )
    self.dateLabel = UILabel( self.ax, self.ay, DATE_LABEL_OFFSET_X, 0, DATE_LABEL_WIDTH, 1, date, 'ui_text_passive', 'left' )

    self:addChild( self.loadButton )
    self:addChild( self.deleteButton )
    self:addChild( self.typeLabel )
    self:addChild( self.versionLabel )
    self:addChild( self.dateLabel )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UISaveGameEntry:receive( msg, _ )
    if msg == 'LOAD_SAVE' then
        if self.valid then
            ScreenManager.switch( 'gamescreen', SaveHandler.load( self.name ))
        end
    elseif msg == 'DELETE_SAVE' then
        self.observable:publish( msg, self )
    end
end

function UISaveGameEntry:observe( observer )
    self.observable:observe( observer )
end

function UISaveGameEntry:draw()
    self.loadButton:draw()
    self.deleteButton:draw()
    self.typeLabel:draw()
    self.versionLabel:draw()
    self.dateLabel:draw()
end

function UISaveGameEntry:command( cmd )
    for i = 1, #self.children do
        if self.children[i]:hasFocus() and self.children[i].command then
            self.children[i]:command( cmd )
            return
        end
    end
end

function UISaveGameEntry:mousecommand( cmd )
    for i = 1, #self.children do
        if self.children[i]:isMouseOver() and self.children[i].mousecommand then
            self.children[i]:mousecommand( cmd )
            return
        end
    end
end

function UISaveGameEntry:setFocus( focus )
    self.loadButton:setFocus( focus )
end

return UISaveGameEntry
