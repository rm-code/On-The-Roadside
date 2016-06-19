local CharacterManager = require( 'src.characters.CharacterManager' );
local MousePointer = require( 'src.ui.MousePointer' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UserInterface = {};

---
-- Creates an new instance of the UserInterface class.
-- @param game (Game)          The game object.
-- @return     (UserInterface) The new instance.
--
function UserInterface.new( game )
    local self = {};

    local mouseX, mouseY = 0, 0;

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        local mx, my = MousePointer.getCameraPosition( mouseX * TILE_SIZE, mouseY * TILE_SIZE );
        love.graphics.rectangle( 'line', mx, my, TILE_SIZE, TILE_SIZE );
    end

    ---
    -- Draws some information of the tile the mouse is currently hovering over.
    --
    local function inspectTile()
        local tile = game:getMap():getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        if not tile:isExplored() then
            love.graphics.print( 'Tile: Unexplored', 310, love.graphics.getHeight() - 20 );
        elseif tile:isOccupied() then
            love.graphics.print( 'Health: ' .. tile:getCharacter():getHealth(), 310, love.graphics.getHeight() - 20 );
        elseif tile:hasWorldObject() then
            love.graphics.print( 'Tile: ' .. tile:getWorldObject():getName(), 310, love.graphics.getHeight() - 20 );
        elseif tile:isExplored() then
            love.graphics.print( 'Tile: ' .. tile:getName(), 310, love.graphics.getHeight() - 20 );
        end
    end

    function self:draw()
        local character = CharacterManager.getCurrentCharacter();

        drawMouseCursor();

        -- Draw tile coordinates.
        love.graphics.print( 'Coords: ' .. mouseX .. ', ' .. mouseY, 10, love.graphics.getHeight() - 20 );

        love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 50, love.graphics.getHeight() - 20 );
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', love.graphics.getWidth() - 110, love.graphics.getHeight() - 20 );

        local weapon = character:getWeapon();
        if weapon then
            love.graphics.print( 'Weapon: ' .. weapon:getName(), 150, love.graphics.getHeight() - 40 );
            love.graphics.print( 'Mode: ' .. character:getWeapon():getFiringMode(), 150, love.graphics.getHeight() - 20 );
            love.graphics.print( 'Ammo: ' .. string.format( '%2d/%2d', weapon:getMagazine():getRounds(), weapon:getMagazine():getCapacity() ), 310, love.graphics.getHeight() - 40 );
        end

        -- Action points
        love.graphics.print( 'AP: ' .. character:getActionPoints(), 10, love.graphics.getHeight() - 40 );

        inspectTile();
    end

    function self:update()
        mouseX, mouseY = MousePointer.getGridPosition();
    end

    return self;
end

return UserInterface;
