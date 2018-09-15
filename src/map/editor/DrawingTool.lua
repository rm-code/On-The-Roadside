---
-- @module DrawingTool
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BaseTool = require( 'src.map.editor.BaseTool' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local DrawingTool = BaseTool:subclass( 'DrawingTool' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function DrawingTool:initialize()
    BaseTool.initialize( self, 'tool_draw' )
end

---
-- Draw
--
function DrawingTool:draw()
    if not self.icon then
        return
    end

    if self.iconColorID then
        TexturePacks.setColor( self.iconColorID )
    end

    local tw, th = TexturePacks.getTileDimensions()
    for x = 0, self.size-1 do
        for y = 0, self.size-1 do
            love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), self.icon, (self.x+x) * tw, (self.y+y) * th )
        end
    end
    TexturePacks.resetColor()
end

function DrawingTool:use( canvas )
    if self.layer and self.active then
        for x = 0, self.size-1 do
            for y = 0, self.size-1 do
                if self.layer == 'worldObject' then
                    canvas:setWorldObject( self.x+x, self.y+y, self.template.id )
                elseif self.layer == 'tile' then
                    canvas:setTile( self.x+x, self.y+y, self.template.id )
                end
            end
        end
    end
end

return DrawingTool
