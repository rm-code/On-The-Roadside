local Queue = require('src.combat.Queue');
local Walk = require( 'src.characters.actions.Walk' );
local PathFinder = require( 'src.combat.PathFinder' );
local CharacterManager = require( 'src.characters.CharacterManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local actionQueue = Queue.new();
    local actionTimer = 0;

    -- Needs to grab next character

    -- ActionQueue for that actor

    -- While turn is not done
        -- Enqueue actions for the character if he has enough AP

    -- When turn is done
    -- Perform all actions on the queue

    local function setTarget( target )
        if target then
            local character = CharacterManager.getCurrentCharacter();
            local origin = character:getTile();
            local path = PathFinder.generatePath( origin, target );

            if path then
                for i = 1, #path do
                    actionQueue:enqueue( Walk.new( character, path[i] ));
                end
            else
                print( "Can't find path!");
            end
        end
    end

    function self:update( dt )
        if actionQueue:getSize() > 0 and actionTimer > 0.15 then
            local action = actionQueue:dequeue();
            action:perform();
            actionTimer = 0;
        end
        actionTimer = actionTimer + dt;
    end

    function self:keypressed( key )
        if key == 'space' then
            actionQueue:clear();
            CharacterManager.nextCharacter();
        end
    end

    function self:mousepressed( mx, my, button )
        if button == 1 then
            actionQueue:clear();
            setTarget( map:getTileAt( mx, my ));
        elseif button == 2 then
            actionQueue:clear();
            CharacterManager.selectCharacter( map:getTileAt( mx, my ));
        end
    end

    return self;
end

return TurnManager;
