local Log = require( 'src.util.Log' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require( 'src.constants.ITEM_TYPES' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the UserInterface class.
-- @param game (Game)          The game object.
-- @tparam CameraHandler camera A camera object used to move the map.
-- @return     (UserInterface) The new instance.
--
function UserInterface.new( game, camera )
    local self = {};

    local map = game:getMap();
    local factions = game:getFactions();
    local mouseX, mouseY = 0, 0;
    local debug = false;
    local font = TexturePacks.getFont()
    local tw, th = TexturePacks.getTileDimensions()

    ---
    -- Draws some information of the tile the mouse is currently hovering over.
    --
    local function inspectTile()
        local x, y = tw, love.graphics.getHeight() - th * 6
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        love.graphics.print( Translator.getText( 'ui_tile' ), x, y );

        local sw = font:measureWidth( Translator.getText( 'ui_tile' ))
        if tile:hasWorldObject() then
            love.graphics.print( Translator.getText( tile:getWorldObject():getID() ), x + sw, y );
        else
            love.graphics.print( Translator.getText( tile:getID() ), x + sw, y );
        end
    end

    local function drawWeaponInfo( inventory, weapon )
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

    local function drawDebugInfo()
        if debug then
            love.graphics.print( love.timer.getFPS() .. ' FPS', tw, th )
            love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', tw, th * 2 )
            love.graphics.print( 'Mouse: ' .. mouseX .. ', ' .. mouseY, tw, th * 3 )
            love.graphics.print( 'Debug Logging: ' .. tostring( Log.getDebugActive() ), tw, th * 4 )
        end
    end

    local function drawActionPoints( character )
        local apString = 'AP: ' .. character:getActionPoints();
        love.graphics.print( apString, tw, love.graphics.getHeight() - th * 5 )

        -- Hide the cost display during the turn's execution.
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

        local mode = game:getState():getInputMode();
        local tile = game:getMap():getTileAt( camera:getMouseWorldGridPosition() )
        local cost;

        if tile then
            if mode:instanceOf( 'AttackInput' ) then
                cost = mode:getPredictedAPCost( character );
            elseif mode:instanceOf( 'InteractionInput' ) then
                cost = mode:getPredictedAPCost( tile, character );
            elseif mode:instanceOf( 'MovementInput' ) and mode:hasPath() then
                cost = mode:getPredictedAPCost();
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

    function self:draw()
        drawDebugInfo();

        local character = factions:getFaction():getCurrentCharacter();
        if factions:getFaction():isAIControlled() then
            return;
        end

        drawActionPoints( character );
        inspectTile();
        drawWeaponInfo( character:getInventory(), character:getWeapon() )
    end

    function self:update()
        mouseX, mouseY = camera:getMouseWorldGridPosition()
    end

    function self:toggleDebugInfo()
        debug = not debug;
    end

    return self;
end

return UserInterface;
