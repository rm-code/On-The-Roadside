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
    local font = love.graphics.newFont( 12 );

    ---
    -- Draws some information of the tile the mouse is currently hovering over.
    --
    local function inspectTile()
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        if tile:isOccupied() then
            love.graphics.print( 'Health: ', 390, love.graphics.getHeight() - 20 );
            love.graphics.print( tile:getCharacter():getHealth(), 390 + font:getWidth( 'Health: ' ), love.graphics.getHeight() - 20 );
            return;
        end

        love.graphics.print( 'Tile: ', 390, love.graphics.getHeight() - 20 );
        if not tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( 'Unexplored', 390 + font:getWidth( 'Tile: ' ), love.graphics.getHeight() - 20 );
        elseif tile:hasWorldObject() then
            love.graphics.print( tile:getWorldObject():getName(), 390 + font:getWidth( 'Tile: ' ), love.graphics.getHeight() - 20 );
        elseif tile:isExplored( factions:getFaction():getType() ) then
            love.graphics.print( tile:getName(), 390 + font:getWidth( 'Tile: ' ), love.graphics.getHeight() - 20 );
        end
    end

    function self:draw()
        love.graphics.setFont( font );
        local character = factions:getFaction():getCurrentCharacter();
        if factions:getFaction():isAIControlled() then
            return;
        end

        -- Draw tile coordinates.
        love.graphics.print( 'Coordinates: ', 10, love.graphics.getHeight() - 20 );
        love.graphics.print( mouseX .. ', ' .. mouseY, 10 + font:getWidth( 'Coordinates: ' ), love.graphics.getHeight() - 20 );

        love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 80, love.graphics.getHeight() - 40 );
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', love.graphics.getWidth() - 80, love.graphics.getHeight() - 20 );

        local weapon = character:getEquipment():getWeapon();
        if weapon then
            love.graphics.print( 'Weapon: ', 200, love.graphics.getHeight() - 40 );
            love.graphics.print( weapon:getName(), 200 + font:getWidth( 'Weapon: ' ), love.graphics.getHeight() - 40 );

            love.graphics.print( 'Mode: ', 200, love.graphics.getHeight() - 20 );
            love.graphics.print( weapon:getAttackMode().name, 200 + font:getWidth( 'Mode: ' ), love.graphics.getHeight() - 20 );

            if weapon:getWeaponType() ~= 'Melee' and weapon:getWeaponType() ~= 'Grenade' then
                love.graphics.print( 'Ammo: ', 390, love.graphics.getHeight() - 40 );
                love.graphics.print( string.format( '%2d/%2d', weapon:getMagazine():getRounds(), weapon:getMagazine():getCapacity() ), 390 + font:getWidth( 'Ammo: ' ), love.graphics.getHeight() - 40 );
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
