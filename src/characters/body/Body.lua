local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );
local StatusEffects = require( 'src.characters.body.StatusEffects' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Body = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' );

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
                statusEffects:add({ STATUS_EFFECTS.DEAD })
            end
        end
    end

    ---
    -- Checks if the body part's node is connected to an equipment slot and if
    -- that equipment slot contains an item of the type clothing. If that's the
    -- case it reduces the damage based on the type of damage and the type of
    -- armor stats the item in the equipment slot has.
    -- @param node       (BodyPart) The body part to damage.
    -- @param damage     (number)   The amount of damage.
    -- @param damageType (string)   The type of damage.
    -- @return           (number)   The modified damage value.
    --
    local function checkArmorProtection( node, damage, _ )
        local slots = equipment:getSlots();
        for _, edge in ipairs( edges ) do
            local slot = slots[edge.from];
            -- If edge.from points to an equipment slot and the edge connects it
            -- to the body part currently receiving damage we check for armor.
            if slot and edge.to == node:getIndex() then
                -- Get the slot contains an item and the item is of type clothing we check
                -- if the attack actually hits a part that is covered by the armor.
                local item = slot:getItem();
                if item and item:instanceOf( 'Armor' ) then
                    Log.debug( 'Body part is protected by armor ' .. item:getID(), 'Body' );
                    if love.math.random( 0, 100 ) < item:getArmorCoverage() then
                        Log.debug( string.format( 'The armor absorbs %d points of damage.', item:getArmorProtection() ), 'Body' );
                        damage = damage - item:getArmorProtection();
                    end
                end
            end
        end
        return damage;
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
        damage = checkArmorProtection( node, damage, damageType );

        -- Stop damage propagation if the armor has stopped all of the incoming damage.
        if damage <= 0 then
            return;
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

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['inventory'] = inventory:serialize(),
            ['equipment'] = equipment:serialize(),
            ['statusEffects'] = statusEffects:serialize()
        };

        -- Serialize body graph's edges.
        t['edges'] = {};
        for i, edge in ipairs( edges ) do
            t['edges'][i] = {
                ['name'] = edge.name,
                ['from'] = edge.from,
                ['to'] = edge.to
            }
        end

        -- Serialize body graph's nodes.
        t['nodes'] = {};
        for i, node in ipairs( nodes ) do
            t['nodes'][i] = node:serialize();
        end

        return t;
    end

    function self:heal()
        -- Restore blood volume.
        bloodVolume = template.bloodVolume

        -- Heal body parts.
        for _, node in pairs( nodes ) do
            node:heal()
        end

        -- Remove status effects.
        statusEffects:remove({ STATUS_EFFECTS.BLIND })
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

    function self:getHeight( stance )
        return template.size[stance];
    end

    return self;
end

return Body;
