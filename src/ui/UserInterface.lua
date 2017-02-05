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

local VERSION_STRING = "WIP - Version: " .. getVersion();
local TILE_SIZE = require( 'src.constants.TileSize' );

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
    local font = ImageFont.getFont();
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

        local sw = font:getWidth( Translator.getText( 'ui_tile' ));
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
            love.graphics.print( text, TILE_SIZE + font:getWidth( Translator.getText( 'ui_weapon' )), love.graphics.getHeight() - TILE_SIZE * 3 );

            love.graphics.print( Translator.getText( 'ui_mode' ), TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 2 );
            love.graphics.print( weapon:getAttackMode().name, TILE_SIZE + font:getWidth( Translator.getText( 'ui_mode' )), love.graphics.getHeight() - TILE_SIZE * 2 );

        end
    end

    local function drawDebugInfo()
        if debug then
            love.graphics.print( love.timer.getFPS() .. ' FPS', TILE_SIZE, TILE_SIZE );
            love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', TILE_SIZE, TILE_SIZE * 2 );
            love.graphics.print( 'Mouse: ' .. mouseX .. ', ' .. mouseY, TILE_SIZE, TILE_SIZE * 3 );
        end
    end

    local function drawHelpInfo()
        love.graphics.setColor( 255, 255, 255, 100 );
        love.graphics.print( VERSION_STRING,        love.graphics.getWidth() - 13 * TILE_SIZE, TILE_SIZE );
        love.graphics.print( 'Press "h" for help!', love.graphics.getWidth() - 13 * TILE_SIZE, TILE_SIZE * 2 );
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    function self:draw()
        love.graphics.setFont( font );
        local character = factions:getFaction():getCurrentCharacter();
        if factions:getFaction():isAIControlled() then
            return;
        end

        love.graphics.print( 'AP: ' .. character:getActionPoints(), TILE_SIZE, love.graphics.getHeight() - TILE_SIZE * 4 );

        inspectTile();

        drawWeaponInfo( character:getWeapon() );
        drawHelpInfo();
        drawDebugInfo();
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
