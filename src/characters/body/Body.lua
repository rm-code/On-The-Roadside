local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );
local StatusEffects = require( 'src.characters.StatusEffects' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Body = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.StatusEffects' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Body.new( template )
    local self = Object.new():addInstance( 'Body' );

    local bloodVolume = template.bloodVolume

    local inventory;
    local equipment;
    local nodes = {};
    local edges = {};
    local statusEffects = StatusEffects.new();

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Ticks the bleeding effects on a node and applies the dead effect to the
    -- character if the blood volume is below zero.
    -- @param node (BodyPart) The bodypart to tick.
    --
    local function handleBleeding( node )
        if node:isBleeding() then
            bloodVolume = bloodVolume - node:getBloodLoss();
            if bloodVolume <= 0 then
                Log.debug( 'Character bleeds to death!', 'Body' );
                statusEffects:add({ STATUS_EFFECTS.DEATH });
            end
        end
    end

    ---
    -- Picks a random entry node and returns it.
    -- @return (BodyPart) The bodypart used as an entry point for the graph.
    --
    local function selectEntryNode()
        local entryNodes = {};
        for _, node in pairs( nodes ) do
            if node:isEntryNode() and not node:isDestroyed() then
                entryNodes[#entryNodes + 1] = node;
            end
        end
        return entryNodes[love.math.random( #entryNodes )];
    end

    ---
    -- Propagates the damage from parent to child nodes.
    -- @param node       (BodyPart) The body part to damage.
    -- @param damage     (number)   The amount of damage.
    -- @param damageType (string)   The type of damage.
    --
    local function destroyChildNodes( node )
        node:destroy();

        -- Add status effects.
        statusEffects:add( node:getEffects() );

        -- Randomly propagate the damage to connected nodes.
        for _, edge in ipairs( edges ) do
            if edge.from == node:getIndex() then
                destroyChildNodes( nodes[edge.to] );
            end
        end
    end

    ---
    -- Propagates the damage from parent to child nodes.
    -- @param node       (BodyPart) The body part to damage.
    -- @param damage     (number)   The amount of damage.
    -- @param damageType (string)   The type of damage.
    --
    local function propagateDamage( node, damage, damageType )
        -- Check if an equipment slot is connected to this body part.
        for _, edge in ipairs( edges ) do
            local slots = equipment:getSlots();
            if slots[edge.from] and edge.to == node:getIndex() then
                Log.debug( '    Equipment slot > ' .. slots[edge.from]:getID(), 'Body' )
                -- TODO damage reduction based on armor items
            end
        end

        node:hit( damage, damageType );
        handleBleeding( node );

        -- Manually destroy child nodes if parent node is destroyed.
        if node:isDestroyed() then
            destroyChildNodes( node );
            return;
        end

        -- Randomly propagate the damage to connected nodes.
        for _, edge in ipairs( edges ) do
            if edge.from == node:getIndex() and not nodes[edge.to]:isDestroyed() and love.math.random( 100 ) < tonumber( edge.name ) then
                propagateDamage( nodes[edge.to], damage, damageType );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:tickOneTurn()
        for _, node in pairs( nodes ) do
            if node:isBleeding() then
                handleBleeding( node );
            end
        end
    end

    function self:hit( damage, damageType )
        local entryNode = selectEntryNode();
        Log.debug( "Attack enters body at " .. entryNode:getID(), 'Body' );

        propagateDamage( entryNode, damage, damageType );
    end

    function self:addBodyPart( bodyPart )
        local index = bodyPart:getIndex();
        assert( not nodes[index], 'ID already used! BodyParts have to be unique.' );
        nodes[index] = bodyPart;
    end

    function self:addConnection( connection )
        edges[#edges + 1] = connection;
    end

    function self:getBodyParts()
        return nodes;
    end

    function self:getBodyPart( id )
        return nodes[id];
    end

    function self:getEquipment()
        return equipment;
    end

    function self:getInventory()
        return inventory;
    end

    function self:setInventory( ninventory )
        inventory = ninventory;
    end

    function self:setEquipment( nequipment )
        equipment = nequipment;
    end

    function self:getStatusEffects()
        return statusEffects;
    end

    function self:getBloodVolume()
        return bloodVolume;
    end

    function self:getTags()
        return template.tags;
    end

    function self:getID()
        return template.id;
    end

    return self;
end

return Body;
