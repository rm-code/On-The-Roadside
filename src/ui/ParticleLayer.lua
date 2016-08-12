local Object = require( 'src.Object' );
local Messenger = require( 'src.Messenger' );
local Particle = require( 'src.ui.Particle' );
local ObjectPool = require( 'src.util.ObjectPool' );

local ParticleLayer = {};

function ParticleLayer.new()
    local self = Object.new():addInstance( 'ParticleLayer' );

    local grid = {};
    local particles = ObjectPool.new( Particle, 'Particle' );

    local function addParticleEffect( x, y, r, g, b, a, fade )
        grid[x] = grid[x] or {};
        -- Return previous particles on this tile to the particle pool.
        if grid[x][y] then
            particles:deposit( grid[x][y] );
        end
        grid[x][y] = particles:request( r, g, b, a, fade );
    end

    function self:update( dt )
        for x, row in pairs( grid ) do
            for y, particle in pairs( row ) do
                particle:update( dt );

                -- Remove the Particle if it is invisible.
                if particle:getAlpha() <= 0 then
                    particles:deposit( particle );
                    grid[x][y] = nil;
                end
            end
        end
    end

    function self:getParticleGrid()
        return grid;
    end

    Messenger.observe( 'PROJECTILE_MOVED', function( ... )
        local projectile = ...;
        local tile = projectile:getTile();
        if tile then
            if projectile:getWeapon():getMagazine():getAmmoType() == 'Rocket' then
                local col = love.math.random( 150, 255 );
                addParticleEffect( tile:getX(), tile:getY(), col, col, col, love.math.random( 100, 255 ), 500 );
                return;
            end
            addParticleEffect( tile:getX(), tile:getY(), 223, 113,  38, 200, 500 );
        end
    end)

    Messenger.observe( 'EXPLOSION', function( ... )
        local generation = ...;
        for tile, life in pairs( generation ) do
            local r = 255;
            local g = love.math.random( 100, 200 );
            local b = 0;
            local a = love.math.random( 200, 255 );
            local fade = 500 / math.min( 3, love.math.random( life ));
            addParticleEffect( tile:getX(), tile:getY(), r, g, b, a, fade );
        end
    end)

    return self;
end

return ParticleLayer;
