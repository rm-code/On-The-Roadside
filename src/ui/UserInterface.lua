local Log = require( 'src.util.Log' );
local MousePointer = require( 'src.ui.MousePointer' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the UserInterface class.
-- @param game (Game)          The game object.
-- @return     (UserInterface) The new instance.
--
function UserInterface.new( game )
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
        local x, y = tw, love.graphics.getHeight() - th * 5
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        love.graphics.print( Translator.getText( 'ui_tile' ), x, y );

        local sw = font:measureWidth( Translator.getText( 'ui_tile' ))
        if not tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( Translator.getText( 'ui_tile_unexplored' ), x + sw, y );
        elseif tile:hasWorldObject() then
            love.graphics.print( Translator.getText( tile:getWorldObject():getID() ), x + sw, y );
        elseif tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( Translator.getText( tile:getID() ), x + sw, y );
        end
    end

    local function drawWeaponInfo( weapon )
        if weapon then
            local text = Translator.getText( weapon:getID() );
            if weapon:isReloadable() then
                text = text .. string.format( ' (%d/%d)', weapon:getMagazine():getRounds(), weapon:getMagazine():getCapacity() )
            end
            love.graphics.print( Translator.getText( 'ui_weapon' ), tw, love.graphics.getHeight() - th * 3 )
            love.graphics.print( text, tw + font:measureWidth( Translator.getText( 'ui_weapon' )), love.graphics.getHeight() - th * 3 )

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
        love.graphics.print( apString, tw, love.graphics.getHeight() - th * 4 )

        -- Hide the cost display during the turn's execution.
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

        local mode = game:getState():getInputMode();
        local tile = game:getMap():getTileAt( MousePointer.getGridPosition() );
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
            love.graphics.print( costString, tw + costOffset, love.graphics.getHeight() - th * 4 )

            local resultString, resultOffset = ' = ' .. character:getActionPoints() - cost, font:measureWidth( apString .. costString )
            TexturePacks.setColor( 'ui_ap_cost_result' )
            love.graphics.print( resultString, tw + resultOffset, love.graphics.getHeight() - th * 4 )
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
        drawWeaponInfo( character:getWeapon() );
    end

    function self:update()
        mouseX, mouseY = MousePointer.getGridPosition();
    end

    function self:toggleDebugInfo()
        debug = not debug;
    end

    return self;
end

return UserInterface;
