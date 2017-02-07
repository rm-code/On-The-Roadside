local State = require( 'src.turnbased.states.State' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InteractionInput = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InteractionInput.new()
    local self = State.new():addInstance( 'InteractionInput' );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Creates opening or closing actions for doors depending on the current
    -- state of the door.
    -- @param target    (Tile)      The tile to act upon.
    -- @param character (Character) The character to create the action for.
    --
    local function handleDoors( target, character )
        if target:isPassable() then
            character:enqueueAction( Close.new( character, target ));
        else
            character:enqueueAction( Open.new( character, target ));
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Requests a new action for a given character.
    -- @param target    (Tile)      The tile to act upon.
    -- @param character (Character) The character to create the action for.
    -- @return          (boolean)   True if an action was created, false otherwise.
    --
    function self:request( target, character )
        -- Characters can only interact with adjacent tiles.
        if not target:isAdjacent( character:getTile() ) then
            return false;
        end

        -- Handle interactions with world objects.
        if target:hasWorldObject() then
            if target:getWorldObject():isOpenable() then
                handleDoors();
            end

            if target:getWorldObject():isContainer() then
                character:enqueueAction( OpenInventory.new( character, target ));
            end
            return true;
        end

        -- Handle interactions with other characters.
        if target:isOccupied() then
            if target:getCharacter():getFaction():getType() == character:getFaction():getType() then
                character:enqueueAction( OpenInventory.new( character, target ));
            end
            return true;
        end

        return false;
    end

    return self;
end

return InteractionInput;
