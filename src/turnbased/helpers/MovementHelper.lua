local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MovementHelper = {};

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function generatePath( target, character )
    if target and not target:isOccupied() then
        local origin = character:getTile();
        local path = PathFinder.generatePath( origin, target, true );

        if path then
            character:addPath( path );
            character:getPath():iterate( function( tile, index )
                if tile:hasWorldObject() and tile:getWorldObject():isOpenable() and not tile:isPassable() then
                    character:enqueueAction( Open.new( character, tile ));
                    -- Don't walk on the door tile if the path ends there.
                    if index ~= 1 then
                        character:enqueueAction( Walk.new( character, tile ));
                    end
                elseif tile:hasWorldObject() and tile:getWorldObject():isClimbable() then
                    character:enqueueAction( ClimbOver.new( character, tile ));
                else
                    character:enqueueAction( Walk.new( character, tile ));
                end
            end)
        end
    end
    print( "Can't find path!");
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MovementHelper.request( map, target, character, states )
    if not character:hasPath() then
        generatePath( target, character );
        character:removeLineOfSight();
    elseif target ~= character:getPath():getTarget() then
        character:clearActions();
        character:removePath();
        character:removeLineOfSight();
        generatePath( target, character );
    else
        states:push( 'execution' );
    end
end

return MovementHelper;
