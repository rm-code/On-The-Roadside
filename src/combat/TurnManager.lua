local Queue = require('src.combat.Queue');
local Walk = require( 'src.characters.actions.Walk' );
local PathFinder = require( 'src.combat.PathFinder' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.enums.Direction' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map, characters )
    local self = {};

    -- TODO CharacterManager
    local actionQueue = Queue.new();
    local characterIndex = 1;
    local actionTimer = 0;

    -- Needs to grab next character

    -- ActionQueue for that actor

    -- While turn is not done
        -- Enqueue actions for the character if he has enough AP

    -- When turn is done
    -- Perform all actions on the queue

    local function setTarget( target )
        if target then
            local origin = characters[characterIndex]:getTile();
            local path = PathFinder.generatePath( origin, target );

            if path then
                for i = 1, #path do
                    actionQueue:enqueue( Walk.new( characters[characterIndex], path[i] ));
                end
            else
                print( "Can't find path!");
            end
        end
    end

    local function endTurn()
        characterIndex = characterIndex == #characters and 1 or characterIndex + 1;
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
            endTurn();
        end
    end

    function self:mousepressed( mx, my )
        actionQueue:clear();
        setTarget( map:getTileAt( mx, my ));
    end

    return self;
end

return TurnManager;
