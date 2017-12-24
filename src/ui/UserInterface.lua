---
-- @module UserInterface
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local Translator = require( 'src.util.Translator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local AttackInput = require( 'src.turnbased.helpers.AttackInput' )
local MovementInput = require( 'src.turnbased.helpers.MovementInput' )
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' )
local ExecutionState = require( 'src.turnbased.states.ExecutionState' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = Class( 'UserInterface' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require( 'src.constants.ITEM_TYPES' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Draws some information of the tile the mouse is currently hovering over.
-- @tparam number mouseX The mouse cursor's position along the x-axis.
-- @tparam number mouseY The mouse cursor's position along the y-axis.
-- @tparam Map    map    The map to inspect.
--
local function inspectTile( mouseX, mouseY, map )
    local font = TexturePacks.getFont()
    local tw, th = TexturePacks.getTileDimensions()

    local x, y = tw, love.graphics.getHeight() - th * 6
    local tile = map:getTileAt( mouseX, mouseY )

    if not tile then
        return
    end

    love.graphics.print( Translator.getText( 'ui_tile' ), x, y )

    local sw = font:measureWidth( Translator.getText( 'ui_tile' ))
    if tile:hasWorldObject() then
        love.graphics.print( Translator.getText( tile:getWorldObject():getID() ), x + sw, y )
    else
        love.graphics.print( Translator.getText( tile:getID() ), x + sw, y )
    end
end

local function drawWeaponInfo( inventory, weapon )
    local font = TexturePacks.getFont()
    local tw, th = TexturePacks.getTileDimensions()

    if weapon then
        love.graphics.print( Translator.getText( 'ui_weapon' ), tw, love.graphics.getHeight() - th * 4 )
        love.graphics.print( Translator.getText( weapon:getID() ), tw + font:measureWidth( Translator.getText( 'ui_weapon' )), love.graphics.getHeight() - th * 4 )

        -- If the weapon is reloadable we show the current ammo in the magazine,
        -- the maximum capacity of the magazine and the total amount of ammo
        -- on the character.
        if weapon:isReloadable() then
            local magazine = weapon:getMagazine()
            local total = inventory:countItems( ITEM_TYPES.AMMO, magazine:getCaliber() )

            local text = string.format( ' %d/%d (%d)', magazine:getNumberOfRounds(), magazine:getCapacity(), total )
            love.graphics.print( Translator.getText( 'ui_ammo' ), tw, love.graphics.getHeight() - th * 3 )
            love.graphics.print( text, tw + font:measureWidth( Translator.getText( 'ui_ammo' )), love.graphics.getHeight() - th * 3 )
        end

        love.graphics.print( Translator.getText( 'ui_mode' ), tw, love.graphics.getHeight() - th * 2 )
        love.graphics.print( weapon:getAttackMode().name, tw + font:measureWidth( Translator.getText( 'ui_mode' )), love.graphics.getHeight() - th * 2 )
    end
end

local function drawDebugInfo( mouseX, mouseY, debug )
    local tw, th = TexturePacks.getTileDimensions()

    if debug then
        love.graphics.print( love.timer.getFPS() .. ' FPS', tw, th )
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', tw, th * 2 )
        love.graphics.print( 'Mouse: ' .. mouseX .. ', ' .. mouseY, tw, th * 3 )
        love.graphics.print( 'Debug Logging: ' .. tostring( Log.getDebugActive() ), tw, th * 4 )
    end
end

local function drawActionPoints( game, camera, character )
    local font = TexturePacks.getFont()
    local tw, th = TexturePacks.getTileDimensions()
    local apString = 'AP: ' .. character:getActionPoints()

    love.graphics.print( apString, tw, love.graphics.getHeight() - th * 5 )

    -- Hide the cost display during the turn's execution.
    if game:getState():isInstanceOf( ExecutionState ) then
        return
    end

    local mode = game:getState():getInputMode()
    local tile = game:getMap():getTileAt( camera:getMouseWorldGridPosition() )
    local cost

    if tile then
        if mode:isInstanceOf( AttackInput ) then
            cost = mode:getPredictedAPCost( character )
        elseif mode:isInstanceOf( InteractionInput ) then
            cost = mode:getPredictedAPCost( tile, character )
        elseif mode:isInstanceOf( MovementInput ) and mode:hasPath() then
            cost = mode:getPredictedAPCost()
        end
    end

    if cost then
        local costString, costOffset = ' - ' .. cost, font:measureWidth( apString )
        TexturePacks.setColor( 'ui_ap_cost' )
        love.graphics.print( costString, tw + costOffset, love.graphics.getHeight() - th * 5 )

        local resultString, resultOffset = ' = ' .. character:getActionPoints() - cost, font:measureWidth( apString .. costString )
        TexturePacks.setColor( 'ui_ap_cost_result' )
        love.graphics.print( resultString, tw + resultOffset, love.graphics.getHeight() - th * 5 )
    end
    TexturePacks.resetColor()
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

    self.mouseX, self.mouseY = 0, 0

    self.debug = false
end

function UserInterface:draw()
    drawDebugInfo( self.mouseX, self.mouseY, self.debug )

    local character = self.factions:getFaction():getCurrentCharacter()
    if self.factions:getFaction():isAIControlled() then
        return
    end

    drawActionPoints( self.game, self.camera, character )
    inspectTile( self.mouseX, self.mouseY, self.map )
    drawWeaponInfo( character:getInventory(), character:getWeapon() )
end

function UserInterface:update()
    self.mouseX, self.mouseY = self.camera:getMouseWorldGridPosition()
end

function UserInterface:toggleDebugInfo()
    self.debug = not self.debug
end

return UserInterface
