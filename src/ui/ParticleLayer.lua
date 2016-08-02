local Object = require( 'src.Object' );
local Messenger = require( 'src.Messenger' );
local Particle = require( 'src.ui.Particle' );
local ObjectPool = require( 'src.util.ObjectPool' );

local ParticleLayer = {};

function ParticleLayer.new()
    local self = Object.new():addInstance( 'ParticleLayer' );

    local grid = {};
    local particles = ObjectPool.new( Particle, 'Particle' );

    local function addParticleEffect( x, y )
        grid[x] = grid[x] or {};
        -- Return previous particles on this tile to the particle pool.
        if grid[x][y] then
            particles:deposit( grid[x][y] );
        end
        grid[x][y] = particles:request( 223, 113,  38, 200, 500 );
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
            addParticleEffect( tile:getPosition() );
        end
    end)

    return self;
end

return ParticleLayer;
