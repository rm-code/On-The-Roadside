local Object = require( 'src.Object' );
local Bresenham = require( 'lib.Bresenham' );

local SPEED = 30;

local Projectile = {};

local function applyVectorRotation( px, py, tx, ty, angle )
    local vx, vy = tx - px, ty - py;

    -- Transform angle from degrees to radians.
    angle = math.rad( angle );

    local nx = vx * math.cos( angle ) - vy * math.sin( angle );
    local ny = vx * math.sin( angle ) + vy * math.cos( angle );

    return px + nx, py + ny;
end

function Projectile.new( character, origin, target, angle )
    local self = Object.new():addInstance( 'Projectile' );

    local weapon = character:getWeapon();

    local tile = origin;
    local px, py = origin:getPosition();
    local tx, ty = target:getPosition();

    local energy = 100;

    local tiles = {};

    local timer = 0;
    local index = 1;

    -- ------------------------------------------------
    -- Target calculations
    -- TODO Move to different class.
    -- ------------------------------------------------

    -- Modify the target tile's location based on the shot' derivation to get
    -- the actual target for this projectile. Floor the values to integers.
    tx, ty = applyVectorRotation( px, py, tx, ty, angle );
    tx, ty = math.floor( tx + 0.5 ), math.floor( ty + 0.5 );

    -- Get the tiles this projectile passes on the way to its target.
    Bresenham.calculateLine( px, py, tx, ty, function( sx, sy )
        -- Ignore the origin.
        if sx ~= px or sy ~= py then
            tiles[#tiles + 1] = { sx, sy };
        end
        return true;
    end)

    function self:update( dt )
        timer = timer + dt * SPEED;
        if timer > 1 then
            index = index + 1;
            timer = 0;
        end
    end

    function self:updateTile( map )
        tile = map:getTileAt( tiles[index][1], tiles[index][2] );
    end

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

    function self:getWeapon()
        return weapon;
    end

    function self:hasMoved( map )
        return tile ~= map:getTileAt( tiles[index][1], tiles[index][2] );
    end

    function self:hasReachedTarget()
        return #tiles == index;
    end

    function self:setEnergy( nenergy )
        energy = nenergy;
    end

    return self;
end

return Projectile;
