local Queue = require('src.combat.Queue');
local Walk = require( 'src.characters.actions.Walk' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.enums.Direction' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( characters )
    local self = {};

    -- TODO CharacterManager
    local actionQueue = Queue.new();
    local characterIndex = 1;

    -- Needs to grab next character

    -- ActionQueue for that actor

    -- While turn is not done
        -- Enqueue actions for the character if he has enough AP

    -- When turn is done
    -- Perform all actions on the queue

    local function endTurn()
        characterIndex = characterIndex == #characters and 1 or characterIndex + 1;
    end

    function self:update()
        if actionQueue:getSize() > 0 then
            local action = actionQueue:dequeue();
            action:perform();
        end
    end

    function self:keypressed( key )
        if key == 'w' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.NORTH ));
        elseif key == 'x' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.SOUTH ));
        elseif key == 'a' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.WEST ));
        elseif key == 'd' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.EAST ));
        elseif key == 'q' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.NORTH_WEST ));
        elseif key == 'e' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.NORTH_EAST ));
        elseif key == 'y' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.SOUTH_WEST ));
        elseif key == 'c' then
            actionQueue:enqueue( Walk.new( characters[characterIndex], DIRECTION.SOUTH_EAST ));
        end

        if key == 'space' then
            endTurn();
        end
    end

    return self;
end

return TurnManager;
