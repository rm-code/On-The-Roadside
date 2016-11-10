local Object = require( 'src.Object' );
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local Crouch = require( 'src.characters.actions.Crouch' );

local MovementInput = {};

local STANCES = require('src.constants.Stances');

function MovementInput.new( stateManager )
    local self = Object.new():addInstance( 'MovementInput' );

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
        print( "Can't find path!");
    end

    function self:request( ... )
        local target, character = ...;

        generatePath( target, character );
        stateManager:push( 'execution', character );
    end

    return self;
end

return MovementInput;
