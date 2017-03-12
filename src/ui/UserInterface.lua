local Log = require( 'src.util.Log' );
local MousePointer = require( 'src.ui.MousePointer' );
local Translator = require( 'src.util.Translator' );
local ImageFont = require( 'src.ui.ImageFont' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );
local COLORS = require( 'src.constants.Colors' );

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

    ---
    -- Draws some information of the tile the mouse is currently hovering over.
    --
    local function inspectTile()
        local x, y = TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 5;
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        love.graphics.print( Translator.getText( 'ui_tile' ), x, y );

        local sw = ImageFont.measureWidth( Translator.getText( 'ui_tile' ));
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
            love.graphics.print( Translator.getText( 'ui_weapon' ), TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 3 );
            love.graphics.print( text, TILE_SIZE + ImageFont.measureWidth( Translator.getText( 'ui_weapon' )), love.graphics.getHeight() - TILE_SIZE * 3 );

            love.graphics.print( Translator.getText( 'ui_mode' ), TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 2 );
            love.graphics.print( weapon:getAttackMode().name, TILE_SIZE + ImageFont.measureWidth( Translator.getText( 'ui_mode' )), love.graphics.getHeight() - TILE_SIZE * 2 );

        end
    end

    local function drawDebugInfo()
        if debug then
            love.graphics.print( love.timer.getFPS() .. ' FPS', TILE_SIZE, TILE_SIZE );
            love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', TILE_SIZE, TILE_SIZE * 2 );
            love.graphics.print( 'Mouse: ' .. mouseX .. ', ' .. mouseY, TILE_SIZE, TILE_SIZE * 3 );
            love.graphics.print( 'Debug Logging: ' .. tostring( Log.getDebugActive() ), TILE_SIZE, TILE_SIZE * 4 );
        end
    end

    local function drawHelpInfo()
        love.graphics.setColor( 255, 255, 255, 100 );
        love.graphics.print( 'Press "h" for help!', love.graphics.getWidth() - 13 * TILE_SIZE, TILE_SIZE * 2 );
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    local function drawActionPoints( character )
        local apString = 'AP: ' .. character:getActionPoints();
        love.graphics.print( apString, TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 4 );

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
            local costString, costOffset = ' - ' .. cost, ImageFont.measureWidth( apString );
            love.graphics.setColor( COLORS.DB27 );
            love.graphics.print( costString, TILE_SIZE + costOffset, love.graphics.getHeight() - TILE_SIZE * 4 );

            local resultString, resultOffset = ' = ' .. character:getActionPoints() - cost, ImageFont.measureWidth( apString .. costString );
            love.graphics.setColor( COLORS.DB10 );
            love.graphics.print( resultString, TILE_SIZE + resultOffset, love.graphics.getHeight() - TILE_SIZE * 4 );
        end
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    function self:draw()
        drawHelpInfo();
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
