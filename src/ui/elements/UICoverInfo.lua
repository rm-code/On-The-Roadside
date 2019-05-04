---
-- @module UICoverInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )
local TilePainter = require( 'src.ui.TilePainter' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UICoverInfo = UIElement:subclass( 'UICoverInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )
local DIRECTION_MODIFIERS = {
    [DIRECTION.NORTH]      = { x =  0, y = -1 },
    [DIRECTION.SOUTH]      = { x =  0, y =  1 },
    [DIRECTION.EAST]       = { x =  1, y =  0 },
    [DIRECTION.WEST]       = { x = -1, y =  0 },
    [DIRECTION.NORTH_EAST] = { x =  1, y = -1 },
    [DIRECTION.NORTH_WEST] = { x = -1, y = -1 },
    [DIRECTION.SOUTH_EAST] = { x =  1, y =  1 },
    [DIRECTION.SOUTH_WEST] = { x = -1, y =  1 }
}

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 5

local TITLE_OFFSET_X = 1
local TITLE_OFFSET_Y = 1

local TARGET_TITLE_OFFSET_X = 7
local TARGET_TITLE_OFFSET_Y = 1

local COVER_GRID_OFFSET_X = 2
local COVER_GRID_OFFSET_Y = 3

local TARGET_COVER_GRID_OFFSET_X = 8
local TARGET_COVER_GRID_OFFSET_Y = 3

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UICoverInfo:initialize( ox, oy, rx, ry )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.tileset = TexturePacks.getTileset()
    self.tw, self.th = self.tileset:getTileDimensions()

    self.textObject = love.graphics.newText( TexturePacks.getFont():get(), Translator.getText( "ui_cover" ))
    self.targetTextObject = love.graphics.newText( TexturePacks.getFont():get(), Translator.getText( "ui_target_cover" ))
end

local function drawCover( tile, tileset, x, y, tw, th )
    if not tile then
        return
    end

    local id = 'no_cover'
    if tile:hasWorldObject() then
        if tile:getWorldObject():isFullCover() then
            id = 'full_cover'
        elseif tile:getWorldObject():isHalfCover() then
            id = 'half_cover'
        end
    end

    TexturePacks.setColor( id )
    love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( id ), x * tw, y * th )
    TexturePacks.resetColor()
end

local function drawCharacter( character, tileset, x, y, tw, th )
    local sprite = TexturePacks.getSprite( character:getCreatureClass(), character:getStance() )
    TexturePacks.setColor( 'allied_active' )
    love.graphics.draw( tileset:getSpritesheet(), sprite, x * tw, y * th )
    TexturePacks.resetColor()
end

local function drawTarget( tile, game, tileset, x, y, tw, th )
    local color = TilePainter.selectTileColor( tile, tile:getWorldObject(), tile:getCharacter(), true, game:getPlayerFaction() )
    local sprite = TexturePacks.getSprite( 'no_cover' )
    love.graphics.setColor( color )
    love.graphics.draw( tileset:getSpritesheet(), sprite, x * tw, y * th )
    TexturePacks.resetColor()
end

function UICoverInfo:draw( game, mouseX, mouseY )
    TexturePacks.setColor( 'ui_text_dark' )
    love.graphics.draw( self.textObject, (self.ax + TITLE_OFFSET_X) * self.tw, (self.ay + TITLE_OFFSET_Y) * self.th )
    love.graphics.draw( self.targetTextObject, (self.ax + TARGET_TITLE_OFFSET_X) * self.tw, (self.ay + TARGET_TITLE_OFFSET_Y) * self.th )
    TexturePacks.resetColor()

    local tile = game:getCurrentCharacter():getTile()
    if tile then
        drawCharacter( game:getCurrentCharacter(), self.tileset, self.ax + COVER_GRID_OFFSET_X, self.ay + COVER_GRID_OFFSET_Y, self.tw, self.th)
    end

    local target = game:getMap():getTileAt( mouseX, mouseY )
    if target then
        drawTarget( target, game, self.tileset, self.ax + TARGET_COVER_GRID_OFFSET_X, self.ay + TARGET_COVER_GRID_OFFSET_Y, self.tw, self.th)
    end

    for dir, mod in pairs( DIRECTION_MODIFIERS ) do
        if tile then
            drawCover( tile:getNeighbour( dir ), self.tileset, self.ax + mod.x + COVER_GRID_OFFSET_X, self.ay + mod.y + COVER_GRID_OFFSET_Y, self.tw, self.th)
        end
        if target then
            drawCover( target:getNeighbour( dir ), self.tileset, self.ax + mod.x + TARGET_COVER_GRID_OFFSET_X, self.ay + mod.y + TARGET_COVER_GRID_OFFSET_Y, self.tw, self.th)
        end
    end

    TexturePacks.resetColor()
end

return UICoverInfo
