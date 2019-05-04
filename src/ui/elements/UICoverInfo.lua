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
local DIRECTION_ID_CENTER = 9
local DIRECTION_MODIFIER_CENTER = { x = 0, y = 0 }

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

local MAX_SPRITES = 9

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Initialises the spritebatch with empty tiles and returns a sprite index.
-- @tparam SpriteBatch spritebatch The spritebatch to initialize.
-- @treturn table                  A table containing the sprite ids for each tile.
--
local function initSpritebatch( spritebatch )
    local tw, th = TexturePacks.getTileDimensions()
    local spriteIndex = {}

    -- Create sprites for neighbour tiles.
    for dir, mod in pairs( DIRECTION_MODIFIERS ) do
        local id = spritebatch:add( TexturePacks.getSprite( 'tile_grass' ), mod.x * tw, mod.y * th )
        spriteIndex[dir] = { id = id, x = mod.x, y = mod.y }
    end

    -- Create sprite for center tile.
    local x, y = DIRECTION_MODIFIER_CENTER.x * tw, DIRECTION_MODIFIER_CENTER.y * th
    local id = spritebatch:add( TexturePacks.getSprite( 'tile_grass' ), x, y )
    spriteIndex[DIRECTION_ID_CENTER] = { id = id, x = x, y = y }

    return spriteIndex
end

local function drawCover( tile, spritebatch, sprite, tw, th )
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

    spritebatch:setColor( TexturePacks.getColor( id ))
    spritebatch:set( sprite.id, TexturePacks.getSprite( id ), sprite.x * tw, sprite.y * th )
end

local function drawTile( tile, game, spritebatch, sprite, tw, th )
    if not tile then
        spritebatch:setColor( TexturePacks.getColor( 'tile_empty' ))
        spritebatch:set( sprite.id, TexturePacks.getSprite( 'tile_empty' ), sprite.x * tw, sprite.y * th )
        return
    end

    spritebatch:setColor( TilePainter.selectTileColor( tile, tile:getWorldObject(), tile:getCharacter(), true, game:getPlayerFaction() ))
    spritebatch:set( sprite.id, TilePainter.selectTileSprite( tile, tile:getWorldObject(), tile:getCharacter(), true, game:getPlayerFaction() ), sprite.x * tw, sprite.y * th )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UICoverInfo:initialize( ox, oy, rx, ry )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.tileset = TexturePacks.getTileset()
    self.tw, self.th = self.tileset:getTileDimensions()

    self.textObject = love.graphics.newText( TexturePacks.getFont():get(), Translator.getText( "ui_cover" ))
    self.targetTextObject = love.graphics.newText( TexturePacks.getFont():get(), Translator.getText( "ui_target_cover" ))

    self.spritebatch = love.graphics.newSpriteBatch( TexturePacks.getTileset():getSpritesheet(), MAX_SPRITES, 'dynamic' )
    self.spriteIndex = initSpritebatch( self.spritebatch )

    self.targetSpritebatch = love.graphics.newSpriteBatch( TexturePacks.getTileset():getSpritesheet(), MAX_SPRITES, 'dynamic' )
    self.targetSpriteIndex = initSpritebatch( self.targetSpritebatch )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UICoverInfo:draw()
    -- Draw headers.
    TexturePacks.setColor( 'ui_text_dark' )
    love.graphics.draw( self.textObject, (self.ax + TITLE_OFFSET_X) * self.tw, (self.ay + TITLE_OFFSET_Y) * self.th )
    love.graphics.draw( self.targetTextObject, (self.ax + TARGET_TITLE_OFFSET_X) * self.tw, (self.ay + TARGET_TITLE_OFFSET_Y) * self.th )
    TexturePacks.resetColor()

    -- Draw tile grids.
    love.graphics.draw( self.spritebatch, (self.ax + COVER_GRID_OFFSET_X) * self.tw, (self.ay + COVER_GRID_OFFSET_Y) * self.th )
    love.graphics.draw( self.targetSpritebatch, (self.ax + TARGET_COVER_GRID_OFFSET_X) * self.tw, (self.ay + TARGET_COVER_GRID_OFFSET_Y) * self.th )

    TexturePacks.resetColor()
end

function UICoverInfo:update( mouseX, mouseY, game )
    -- Update center of character cover grid.
    local tile = game:getCurrentCharacter():getTile()
    drawTile( tile, game, self.spritebatch, self.spriteIndex[DIRECTION_ID_CENTER], self.tw, self.th )

    -- Update center of target cover grid.
    local target = game:getMap():getTileAt( mouseX, mouseY )
    drawTile( target, game, self.targetSpritebatch, self.targetSpriteIndex[DIRECTION_ID_CENTER], self.tw, self.th )

    -- Update the cover tiles for both grids.
    for dir, _ in pairs( DIRECTION_MODIFIERS ) do
        if tile then
            drawCover( tile:getNeighbour( dir ), self.spritebatch, self.spriteIndex[dir], self.tw, self.th )
        end
        if target then
            drawCover( target:getNeighbour( dir ), self.targetSpritebatch, self.targetSpriteIndex[dir], self.tw, self.th )
        end
    end
end

return UICoverInfo
