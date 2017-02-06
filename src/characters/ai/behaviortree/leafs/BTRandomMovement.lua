local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );
local Crouch = require( 'src.characters.actions.Crouch' );

local BTRandomMovement = {};

local STANCES = require('src.constants.Stances');

function BTRandomMovement.new()
    local self = BTLeaf.new():addInstance( 'BTRandomMovement' );

    local function generatePath( target, character )
        if target and not target:isOccupied() then
            local origin = character:getTile();
            local path = PathFinder.generatePath( origin, target, true );

            if path then
                path:iterate( function( tile, index )
                    if tile:hasWorldObject() then
                        if character:getStance() == STANCES.PRONE then
                            character:enqueueAction( Crouch.new( character ));
                        end
                        if tile:getWorldObject():isOpenable() then
                            if not tile:isPassable() then
                                character:enqueueAction( Open.new( character, tile ));
                                -- Don't walk on the door tile if the path ends there.
                                if index ~= 1 then
                                    character:enqueueAction( Walk.new( character, tile ));
                                end
                            else
                                character:enqueueAction( Walk.new( character, tile ));
                            end
                        elseif tile:getWorldObject():isClimbable() then
                            character:enqueueAction( ClimbOver.new( character, tile ));
                        end
                    else
                        character:enqueueAction( Walk.new( character, tile ));
                    end
                end)
                return;
            end
        end
        Log.info( "Can't find path!");
    end

    function self:traverse( ... )
        Log.info( 'BTRandomMovement' );
        local _, character, states = ...;

        local tiles = {};

        -- Get the character's FOV and store the tiles in a sequence for easier access.
        local fov = character:getFOV();
        for _, rx in pairs( fov ) do
            for _, target in pairs( rx ) do
                tiles[#tiles + 1] = target;
            end
        end

        local target = tiles[love.math.random( 1, #tiles )];
        if target and target:isPassable() and not target:isOccupied() then
            generatePath( target, character );
            states:push( 'execution', character );
            return true;
        end

        return true;
    end

    return self;
end

return BTRandomMovement;
