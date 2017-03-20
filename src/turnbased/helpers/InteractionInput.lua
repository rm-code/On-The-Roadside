local State = require( 'src.turnbased.states.State' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

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
        -- Check health of enemy characters.
        if target:isOccupied() and target:getCharacter():getFaction():getType() ~= character:getFaction():getType() then
            ScreenManager.push( 'health', target:getCharacter() );
            return true;
        end

        -- Characters can only interact with adjacent tiles.
        if not target:isAdjacent( character:getTile() ) then
            return false;
        end

        -- Handle interactions with world objects.
        if target:hasWorldObject() then
            if target:getWorldObject():isOpenable() then
                handleDoors( target, character );
                return true;
            end

            if target:getWorldObject():isContainer() then
                character:enqueueAction( OpenInventory.new( character, target ));
                return true;
            end
            return false;
        end

        -- Handle interactions with other characters.
        if target:isOccupied() then
            if target:getCharacter():getFaction():getType() == character:getFaction():getType() then
                character:enqueueAction( OpenInventory.new( character, target ));
                return true;
            end
            return false;
        end

        -- Allow interaction with empty adjacent tiles.
        character:enqueueAction( OpenInventory.new( character, target ))
        return true;
    end

    ---
    -- Returns the predicted ap cost for this action.
    -- @param target    (Tile)      The tile to interact with.
    -- @param character (Character) The character taking the action.
    -- @return          (number)    The cost.
    --
    function self:getPredictedAPCost( target, character )
        if target:hasWorldObject() then
            return target:getWorldObject():getInteractionCost( character:getStance() ) or 0;
        end
        return 0;
    end

    return self;
end

return InteractionInput;
