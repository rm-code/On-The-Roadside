local Object = require( 'src.Object' );
local Messenger = require( 'src.Messenger' );
local Particle = require( 'src.ui.Particle' );

local ParticleLayer = {};

function ParticleLayer.new()
    local self = Object.new():addInstance( 'ParticleLayer' );

    local grid = {};

    local function addParticleEffect( x, y )
        grid[x] = grid[x] or {};
        grid[x][y] = Particle.new( 223, 113,  38, 200 );
    end

    function self:update( dt )
        for x, row in pairs( grid ) do
            for y, particle in pairs( row ) do
                particle:update( dt );

                -- Remove the Particle if it is invisible.
                if particle:getAlpha() < 0 then
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
