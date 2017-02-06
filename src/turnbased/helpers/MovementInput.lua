local State = require( 'src.turnbased.states.State' );
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );
local Crouch = require( 'src.characters.actions.Crouch' );

local MovementInput = {};

local STANCES = require('src.constants.Stances');

function MovementInput.new()
    local self = State.new():addInstance( 'MovementInput' );

    local path;

    local function generatePath( target, character )
        if target and not target:isOccupied() then
            local origin = character:getTile();
            path = PathFinder.generatePath( origin, target, true );
        end
    end

    local function usePath( character )
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
            path = nil;
        end
    end

    function self:request( ... )
        local target, character = ...;
        if not path or target ~= path:getTarget() then
            generatePath( target, character );
            return false;
        else
            usePath( character );
            return true;
        end
    end

    function self:hasPath()
        return path ~= nil;
    end

    function self:getPath()
        return path;
    end

    return self;
end

return MovementInput;
