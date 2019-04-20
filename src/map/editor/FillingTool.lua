---
-- @module FillingTool
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BaseTool = require( 'src.map.editor.BaseTool' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Queue = require( 'src.util.Queue' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FillingTool = BaseTool:subclass( 'FillingTool' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function floodFill( start )
    local frontier = Queue()
    frontier:enqueue( start )

    local visited = {}
    visited[start] = true

    while not frontier:isEmpty() do
        local current = frontier:dequeue()

        local neighbours = {
            current:getNeighbour( DIRECTION.NORTH ),
            current:getNeighbour( DIRECTION.EAST  ),
            current:getNeighbour( DIRECTION.SOUTH ),
            current:getNeighbour( DIRECTION.WEST  )
        }
        for _, next in pairs( neighbours ) do
            if not visited[next] and next:getID() == start:getID() then
                frontier:enqueue( next )
                visited[next] = true
            end
        end
    end

    return visited
end

local function floodFillWorldObjects( start )
    local frontier = Queue()
    frontier:enqueue( start )

    local visited = {}
    visited[start] = true

    local fillID = start:hasWorldObject() and start:getWorldObject():getID() or 'nil'

    while not frontier:isEmpty() do
        local current = frontier:dequeue()

        local neighbours = {
            current:getNeighbour( DIRECTION.NORTH ),
            current:getNeighbour( DIRECTION.EAST  ),
            current:getNeighbour( DIRECTION.SOUTH ),
            current:getNeighbour( DIRECTION.WEST  )
        }
        for _, next in pairs( neighbours ) do
            if not visited[next] then
                if ( next:hasWorldObject() and next:getWorldObject():getID() == fillID )
                or ( not next:hasWorldObject() and fillID == 'nil' ) then
                    frontier:enqueue( next )
                    visited[next] = true
                end
            end
        end
    end

    return visited
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FillingTool:initialize()
    BaseTool.initialize( self, 'tool_fill' )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function FillingTool:draw()
    if not self.icon then
        return
    end

    if self.iconColorID then
        TexturePacks.setColor( self.iconColorID )
    end

    local tw, th = TexturePacks.getTileDimensions()
    love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), self.icon, self.x * tw, self.y * th )
    TexturePacks.resetColor()
end

function FillingTool:use( canvas )
    if not canvas:getTileAt( self.x, self.y ) then
        return
    end

    if self.layer and self.active then
        if self.layer == 'worldObject' then
            local worldObjects = floodFillWorldObjects( canvas:getTileAt( self.x, self.y ))
            for object, _ in pairs( worldObjects ) do
                local x, y = object:getPosition()
                canvas:setWorldObject( x, y, self.template.id )
            end
        elseif self.layer == 'tile' then
            local tiles = floodFill( canvas:getTileAt( self.x, self.y ))
            for object, _ in pairs( tiles ) do
                local x, y = object:getPosition()
                canvas:setTile( x, y, self.template.id )
            end
        end
    end
end

function FillingTool:increaseSize()
    return
end

function FillingTool:decreaseSize()
    return
end

return FillingTool
