local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );

local BTMoveToTarget = {};

function BTMoveToTarget.new()
    local self = BTLeaf.new():addInstance( 'BTMoveToTarget' );

    local function generatePath( target, character )
        if target and not target:isOccupied() then
            local path = PathFinder.generatePath( character, target, true );

            if path then
                path:iterate( function( tile, index )
                    if tile:hasWorldObject() then
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
        Log.info( 'BTMoveToTarget' );
        local blackboard, character, states, factions = ...;

        local closest;
        local distance;

        -- Find the closest neighbour tile to move to.
        for _, neighbour in pairs( blackboard.target:getNeighbours() ) do
            if neighbour:isPassable() and not neighbour:isOccupied() then
                if not closest then
                    closest = neighbour;
                    local px, py = closest:getPosition();
                    local cx, cy = character:getTile():getPosition();
                    distance = math.sqrt(( px - cx ) * ( px - cx ) + ( py - cy ) * ( py - cy ));
                else
                    local px, py = neighbour:getPosition();
                    local cx, cy = character:getTile():getPosition();
                    local newDistance = math.sqrt(( px - cx ) * ( px - cx ) + ( py - cy ) * ( py - cy ));
                    if newDistance < distance then
                        closest = neighbour;
                        distance = newDistance;
                    end
                end
            end
        end

        if closest then
            generatePath( closest, character );
            states:push( 'execution', factions, character );
            Log.info( 'Character moves to target.' );
            return true;
        end

        return true;
    end

    return self;
end

return BTMoveToTarget;
