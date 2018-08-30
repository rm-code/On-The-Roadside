---
-- @module PrefabBrush
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabBrush = Class( 'PrefabBrush' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local CURSOR_SIZES = {
    { w = 1, h = 1 },
    { w = 2, h = 2 },
    { w = 3, h = 3 },
    { w = 4, h = 4 },
    { w = 5, h = 5 }
}

local SPRITES = {
    ['draw'] = 'prefab_editor_cursor_draw',
    ['fill'] = 'prefab_editor_cursor_fill',
    ['erase'] = 'prefab_editor_cursor_erase'
}

-- ------------------------------------------------
-- Private methods
-- ------------------------------------------------

local function place( canvas, x, y, type, template )
    canvas:setTile( x, y, type, template )
end

local function erase( canvas, x, y, type )
    canvas:setTile( x, y, type, nil )
end

local function fill( canvas, x, y, type, template, toFill )
    if not canvas:exists( x, y ) then
        return
    end

    local tile = canvas:getTileID( x, y, type )
    if tile == toFill and tile ~= template.id then
        canvas:setTile( x, y, type, template )
    else
        return
    end

    fill( canvas, x-1, y, type, template, toFill )
    fill( canvas, x+1, y, type, template, toFill )
    fill( canvas, x, y-1, type, template, toFill )
    fill( canvas, x, y+1, type, template, toFill )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PrefabBrush:initialize()
    self.cursor = 1
    self.mode = 'draw'
    self.active = false

    self.template = nil
    self.type = nil

    self.x, self.y = 0, 0
end

function PrefabBrush:draw()
    love.graphics.setColor( 200, 0, 0, 100 )

    local tw, th = TexturePacks.getTileDimensions()
    local tileset = TexturePacks.getTileset()
    local spritesheet = tileset:getSpritesheet()
    local sprite = TexturePacks.getSprite( SPRITES[self.mode] )

    for x = 1, CURSOR_SIZES[self.cursor].w do
        for y = 1, CURSOR_SIZES[self.cursor].h do
            love.graphics.draw( spritesheet, sprite, (self.x + x - 1) * tw, (self.y + y - 1) * th )
        end
    end

    TexturePacks.resetColor()
end

function PrefabBrush:use( canvas )
    if self.type and self.active then
        for x = 1, CURSOR_SIZES[self.cursor].w do
            for y = 1, CURSOR_SIZES[self.cursor].h do
                local px, py = self.x + x - 1, self.y + y - 1
                if self.mode == 'draw' then
                    place( canvas, px, py, self.type, self.template )
                elseif self.mode == 'erase' then
                    erase( canvas, px, py, self.type )
                elseif self.mode == 'fill' then
                    fill( canvas, px, py, self.type, self.template, canvas:getTileID( x, y, self.type ))
                end
            end
        end
    end
end

function PrefabBrush:increase()
    if self.mode == 'fill' then
        self.cursor = 1
    end
    self.cursor = math.min( self.cursor + 1, #CURSOR_SIZES )
end

function PrefabBrush:decrease()
    if self.mode == 'fill' then
        self.cursor = 1
    end
    self.cursor = math.max( self.cursor - 1, 1 )
end

function PrefabBrush:setActive( nactive )
    self.active = nactive
end

function PrefabBrush:setPosition( nx, ny )
    self.x, self.y = nx, ny
end

function PrefabBrush:getBrush()
    return self.template, self.type
end

function PrefabBrush:setBrush( template, type )
    self.template = template
    self.type = type
end

function PrefabBrush:setMode( mode )
    if mode == 'fill' then
        self.cursor = 1
    end
    self.mode = mode
end

return PrefabBrush
