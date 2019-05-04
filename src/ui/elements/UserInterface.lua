---
-- @module UserInterface
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local Log = require( 'src.util.Log' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICharacterInfo = require( 'src.ui.elements.UICharacterInfo' )
local UITileInfo = require( 'src.ui.elements.UITileInfo' )
local UICoverInfo = require( 'src.ui.elements.UICoverInfo' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local GridHelper = require( 'src.util.GridHelper' )
local UIMessageLog = require( 'src.ui.elements.UIMessageLog' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = UIElement:subclass( 'UserInterface' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function drawDebugInfo( mouseX, mouseY, debug )
    local tw, th = TexturePacks.getTileDimensions()

    if debug then
        love.graphics.print( love.timer.getFPS() .. ' FPS', tw, th )
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', tw, th * 2 )
        love.graphics.print( 'Mouse: ' .. mouseX .. ', ' .. mouseY, tw, th * 3 )
        love.graphics.print( 'Debug Logging: ' .. tostring( Log.getDebugActive() ), tw, th * 4 )
    end
end

local function getPositionAndDimensions()
    local sw, sh = GridHelper.getScreenGridDimensions()
    return sw - UI_GRID_WIDTH, 0, 0, 0, UI_GRID_WIDTH, sh
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes an new instance of the UserInterface class.
-- @tparam Game          game   The game object.
-- @tparam CameraHandler camera A camera object used to move the map.
--
function UserInterface:initialize( game, camera )
    local px, py, rx, ry, w, h = getPositionAndDimensions()
    UIElement.initialize( self, px, py, rx, ry, w, h )

    self.game = game
    self.map = game:getMap()
    self.factions = game:getFactions()
    self.camera = camera

    self.background = UIBackground( px, py, rx, ry, w, h )
    self.characterInfo = UICharacterInfo( px, py )
    self.coverInfo = UICoverInfo( px, py, 0, self.characterInfo:getHeight() )
    self.tileInfo = UITileInfo( px, py, 0, self.characterInfo:getHeight() + self.coverInfo:getHeight() )
    self.msgLog = UIMessageLog( px, py, 0, self.characterInfo:getHeight() + self.tileInfo:getHeight() + self.coverInfo:getHeight() )

    self:addChild( self.background )
    self:addChild( self.characterInfo )
    self:addChild( self.tileInfo )
    self:addChild( self.coverInfo )
    self:addChild( self.msgLog )

    self.mouseX, self.mouseY = 0, 0

    self.debug = false
end

function UserInterface:draw()
    drawDebugInfo( self.mouseX, self.mouseY, self.debug )

    if self.factions:getFaction():isAIControlled() then
        return
    end

    self.background:draw()
    self.characterInfo:draw()
    self.tileInfo:draw()
    self.coverInfo:draw()
    self.msgLog:draw()
end

function UserInterface:update()
    self.mouseX, self.mouseY = self.camera:getMouseWorldGridPosition()

    self.characterInfo:update( self.game:getState(), self.map, self.camera, self.factions:getFaction():getCurrentCharacter() )
    self.tileInfo:update( self.mouseX, self.mouseY, self.map )
    self.coverInfo:update( self.mouseX, self.mouseY, self.game )
    self.msgLog:update()
end

function UserInterface:toggleDebugInfo()
    self.debug = not self.debug
end

function UserInterface:resize()
    local px, py, _, _, _, _ = getPositionAndDimensions()
    self:setOrigin( px, py )

    self.msgLog:resize()
end

return UserInterface
