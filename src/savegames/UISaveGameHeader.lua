---
-- @module UISaveGameHeader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )

local UIElement = require( 'src.ui.elements.UIElement' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UISaveGameHeader = UIElement:subclass( 'UISaveGameHeader' )

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

local DELETE_LABEL_OFFSET_X = DATE_LABEL_OFFSET_X + DATE_LABEL_WIDTH
local DELETE_LABEL_WIDTH = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UISaveGameHeader:initialize( ry )
    local cx, _ = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    UIElement.initialize( self, cx, ry, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.nameLabel = UILabel( self.ax, self.ay, 0, 0, TYPE_LABEL_WIDTH, 1, Translator.getText( 'ui_savename' ), 'ui_text_passive', 'left' )
    self.typeLabel = UILabel( self.ax, self.ay, TYPE_LABEL_OFFSET_X, 0, TYPE_LABEL_WIDTH, 1, Translator.getText( 'ui_type' ), 'ui_text_passive', 'left' )
    self.versionLabel = UILabel( self.ax, self.ay, VERSION_LABEL_OFFSET_X, 0, VERSION_LABEL_WIDTH, 1, Translator.getText( 'ui_version' ), 'ui_text_passive', 'left' )
    self.dateLabel = UILabel( self.ax, self.ay, DATE_LABEL_OFFSET_X, 0, DATE_LABEL_WIDTH, 1, Translator.getText( 'ui_date' ), 'ui_text_passive', 'left' )
    self.deleteLabel = UILabel( self.ax, self.ay, DELETE_LABEL_OFFSET_X, 0, DELETE_LABEL_WIDTH, 1, Translator.getText( 'ui_delete' ), 'ui_text_passive', 'left' )

    self:addChild( self.nameLabel )
    self:addChild( self.typeLabel )
    self:addChild( self.versionLabel )
    self:addChild( self.dateLabel )
    self:addChild( self.deleteLabel )
end

function UISaveGameHeader:draw()
    for i = 1, #self.children do
        self.children[i]:draw()
    end
end

return UISaveGameHeader
