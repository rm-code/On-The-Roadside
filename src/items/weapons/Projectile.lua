local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Projectile = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SPEED = 30;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Projectile.
-- @param character (Character)  The character this projectile belongs to.
-- @param tiles     (table)      A sequence containing all tiles this projectile will pass.
-- @return          (Projectile) A new instance of the Projectile class.
--
function Projectile.new( character, tiles )
    local self = Object.new():addInstance( 'Projectile' );

    local weapon = character:getEquipment():getWeapon();
    local energy = 100;
    local timer = 0;
    local index = 1;
    local tile = character:getTile();
    local previousTile;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        timer = timer + dt * SPEED;
        if timer > 1 and index < #tiles then
            index = index + 1;
            timer = 0;
        end
    end

    function self:updateTile( map )
        previousTile = tile;
        tile = map:getTileAt( tiles[index].x, tiles[index].y );
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCharacter()
        return character;
    end

    function self:getDamage()
        return weapon:getDamage();
    end

    function self:getEnergy()
        return energy;
    end

    function self:getTile()
        return tile;
    end

    function self:getPreviousTile()
        return previousTile;
    end

    function self:getWeapon()
        return weapon;
    end

    function self:hasMoved( map )
        return tile ~= map:getTileAt( tiles[index].x, tiles[index].y );
    end

    function self:hasReachedTarget()
        return #tiles == index;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setEnergy( nenergy )
        energy = nenergy;
    end

    return self;
end

return Projectile;
