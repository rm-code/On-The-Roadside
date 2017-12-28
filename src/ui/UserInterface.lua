---
-- @module UserInterface
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICharacterInfo = require( 'src.ui.elements.UICharacterInfo' )
local UITileInfo = require( 'src.ui.elements.UITileInfo' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = Class( 'UserInterface' )

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

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes an new instance of the UserInterface class.
-- @tparam Game          game   The game object.
-- @tparam CameraHandler camera A camera object used to move the map.
--
function UserInterface:initialize( game, camera )
    self.game = game
    self.map = game:getMap()
    self.factions = game:getFactions()
    self.camera = camera

    self.characterInfo = UICharacterInfo()
    self.tileInfo = UITileInfo()

    self.mouseX, self.mouseY = 0, 0

    self.debug = false
end

function UserInterface:draw()
    drawDebugInfo( self.mouseX, self.mouseY, self.debug )

    if self.factions:getFaction():isAIControlled() then
        return
    end

    self.characterInfo:draw()
    self.tileInfo:draw()
end

function UserInterface:update()
    self.mouseX, self.mouseY = self.camera:getMouseWorldGridPosition()

    self.characterInfo:update( self.game:getState(), self.map, self.camera, self.factions:getFaction():getCurrentCharacter() )
    self.tileInfo:update( self.mouseX, self.mouseY, self.map )
end

function UserInterface:toggleDebugInfo()
    self.debug = not self.debug
end

return UserInterface
