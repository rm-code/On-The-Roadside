---
-- @module UIMessageLog
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local MessageQueue = require( 'src.util.MessageQueue' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIMessageLog = UIElement:subclass( 'UIMessageLog' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 16
local UI_GRID_HEIGHT = 12

local MAX_MESSAGES = 100

local COLORS = {
    INFO      = 'ui_msg_info',
    IMPORTANT = 'ui_msg_important',
    DANGER    = 'ui_msg_danger',
    WARNING   = 'ui_msg_warning'
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function selectColor( i, messages )
    if i == #messages then
        return TexturePacks.getColor( COLORS[messages[i].type] )
    end
    return TexturePacks.getColor( 'ui_text_dark' )
end

local function generateTextObject( textObject, messages, coloredTextTable, width )
    textObject:clear()

    local height = 0
    for i = 1, #messages do
        coloredTextTable[1] = selectColor( i, messages )
        coloredTextTable[2] = messages[i].text

        -- Identical messages get merged. We append the amount of merged messages to the text.
        if messages[i].count > 1 then
            coloredTextTable[2] = coloredTextTable[2] .. string.format( ' (%d)', messages[i].count )
        end

        local id = textObject:addf( coloredTextTable, width, 'left', 0, height )
        height = height + textObject:getHeight( id )
    end
    return height
end

local function mergeMessages( msg, messages )
    local front = messages[#messages]
    if not front then
        return false
    end
    if front.text == msg.text then
        front.count = front.count + 1
        return true
    end
    return false
end

local function registerMessage( msg, messages )
    local merged = mergeMessages( msg, messages )

    if not merged then
        messages[#messages + 1] = msg
        if #messages > MAX_MESSAGES then
            table.remove( messages, 1 )
        end
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIMessageLog:initialize()
    local sw, sh = GridHelper.getScreenGridDimensions()
    UIElement.initialize( self, sw - UI_GRID_WIDTH, sh - UI_GRID_HEIGHT, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.ax, self.ay, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self:addChild( self.background )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )

    self.messages = {}
    self.colorTextTable = {}

    self.verticalOffset = 0
end

function UIMessageLog:draw()
    local tw, th = TexturePacks.getTileDimensions()

    self.background:draw()

    love.graphics.setScissor( self.ax * tw, self.ay * th, UI_GRID_WIDTH * tw, UI_GRID_HEIGHT * th )
    love.graphics.draw( self.textObject, (self.ax+1) * tw, (self.ay + UI_GRID_HEIGHT) * th - self.verticalOffset )
    love.graphics.setScissor()
end

function UIMessageLog:update()
    if not MessageQueue.isEmpty() then
        local tw, _ = TexturePacks.getTileDimensions()
        registerMessage( MessageQueue.dequeue(), self.messages, self.textObject, self.colorTextTable )
        self.verticalOffset = generateTextObject( self.textObject, self.messages, self.colorTextTable, (self.w-1) * tw )
    end
end

return UIMessageLog
