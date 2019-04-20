---
-- @module EraserTool
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BaseTool = require( 'src.map.editor.BaseTool' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local EraserTool = BaseTool:subclass( 'EraserTool' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SPRITE = 'prefab_editor_cursor_erase'

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function EraserTool:initialize()
    BaseTool.initialize( self, 'tool_erase' )
end

function EraserTool:draw()
    if self.iconColorID then
        TexturePacks.setColor( self.iconColorID )
    end

    local tw, th = TexturePacks.getTileDimensions()
    for x = 0, self.size-1 do
        for y = 0, self.size-1 do
            love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), TexturePacks.getSprite( SPRITE ), (self.x+x) * tw, (self.y+y) * th )
        end
    end
    TexturePacks.resetColor()
end

function EraserTool:use( canvas )
    if self.layer and self.active then
        for x = 0, self.size-1 do
            for y = 0, self.size-1 do
                if self.layer == 'worldObject' then
                    canvas:removeWorldObject( self.x+x, self.y+y )
                elseif self.layer == 'tile' then
                    canvas:removeTile( self.x+x, self.y+y )
                end
            end
        end
    end
end

return EraserTool
