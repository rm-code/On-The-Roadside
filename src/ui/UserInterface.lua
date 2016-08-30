local MousePointer = require( 'src.ui.MousePointer' );

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

    local map = game:getMap();
    local factions = game:getFactions();
    local mouseX, mouseY = 0, 0;

    ---
    -- Draws some information of the tile the mouse is currently hovering over.
    --
    local function inspectTile()
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        if not tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( 'Tile: Unexplored', 310, love.graphics.getHeight() - 20 );
        elseif tile:isOccupied() then
            love.graphics.print( 'Health: ' .. tile:getCharacter():getHealth(), 310, love.graphics.getHeight() - 20 );
        elseif tile:hasWorldObject() then
            love.graphics.print( 'Tile: ' .. tile:getWorldObject():getName(), 310, love.graphics.getHeight() - 20 );
        elseif tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( 'Tile: ' .. tile:getName(), 310, love.graphics.getHeight() - 20 );
        end
    end

    function self:draw()
        local character = factions:getFaction():getCurrentCharacter();

        -- Draw tile coordinates.
        love.graphics.print( 'Coords: ' .. mouseX .. ', ' .. mouseY, 10, love.graphics.getHeight() - 20 );

        love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 80, love.graphics.getHeight() - 40 );
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', love.graphics.getWidth() - 80, love.graphics.getHeight() - 20 );

        local weapon = character:getEquipment():getWeapon();
        if weapon then
            love.graphics.print( 'Weapon: ' .. weapon:getName(), 150, love.graphics.getHeight() - 40 );
            love.graphics.print( 'Mode: ' .. weapon:getAttackMode().name, 150, love.graphics.getHeight() - 20 );
            if weapon:getWeaponType() ~= 'Melee' then
                love.graphics.print( 'Ammo: ' .. string.format( '%2d/%2d', weapon:getMagazine():getRounds(), weapon:getMagazine():getCapacity() ), 310, love.graphics.getHeight() - 40 );
            end
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
