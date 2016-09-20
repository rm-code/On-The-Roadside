local MousePointer = require( 'src.ui.MousePointer' );
local Translator = require( 'src.util.Translator' );

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
        local x, y = 390, love.graphics.getHeight() - 20;
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        if tile:isOccupied() then
            love.graphics.print( Translator.getText( 'ui_health' ), x, y );
            love.graphics.print( tile:getCharacter():getHealth(), x + font:getWidth( Translator.getText( 'ui_health' )), y );
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

    function self:draw()
        love.graphics.setFont( font );
        local character = factions:getFaction():getCurrentCharacter();
        if factions:getFaction():isAIControlled() then
            return;
        end

        -- Draw tile coordinates.
        love.graphics.print( Translator.getText( 'ui_coordinates' ), 10, love.graphics.getHeight() - 20 );
        love.graphics.print( mouseX .. ', ' .. mouseY, 10 + font:getWidth( Translator.getText( 'ui_coordinates' )), love.graphics.getHeight() - 20 );

        love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 80, love.graphics.getHeight() - 40 );
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', love.graphics.getWidth() - 80, love.graphics.getHeight() - 20 );

        local weapon = character:getInventory():getWeapon();
        if weapon then
            love.graphics.print( Translator.getText( 'ui_weapon' ), 200, love.graphics.getHeight() - 40 );
            love.graphics.print( Translator.getText( weapon:getID() ), 200 + font:getWidth( Translator.getText( 'ui_weapon' )), love.graphics.getHeight() - 40 );

            love.graphics.print( Translator.getText( 'ui_mode' ), 200, love.graphics.getHeight() - 20 );
            love.graphics.print( weapon:getAttackMode().name, 200 + font:getWidth( Translator.getText( 'ui_mode' )), love.graphics.getHeight() - 20 );

            if weapon:getWeaponType() ~= 'Melee' and weapon:getWeaponType() ~= 'Grenade' then
                love.graphics.print( Translator.getText( 'ui_ammo' ), 390, love.graphics.getHeight() - 40 );
                love.graphics.print( string.format( '%2d/%2d', weapon:getMagazine():getRounds(), weapon:getMagazine():getCapacity() ), 390 + font:getWidth( Translator.getText( 'ui_ammo' )), love.graphics.getHeight() - 40 );
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
