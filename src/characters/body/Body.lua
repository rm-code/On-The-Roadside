local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Body = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Body.new()
    local self = Object.new():addInstance( 'Body' );

    local nodes = {};
    local edges = {};
    local dead  = false;
    local blind = false;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Picks a random entry node and returns it.
    -- @return (BodyPart) The bodypart used as an entry point for the graph.
    --
    local function selectEntryNode()
        local entryNodes = {};
        for _, node in pairs( nodes ) do
            if node:isEntryNode() then
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
    local function propagateDamage( node, damage, damageType )
        node:hit( damage, damageType );

        -- Randomly propagate the damage to connected nodes.
        for _, edge in ipairs( edges ) do
            if edge.from == node:getIndex() and love.math.random( 100 ) < edge.name then
                propagateDamage( nodes[edge.to], damage, damageType );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:hit( damage, damageType )
        local entryNode = selectEntryNode();
        print( "Attack enters body at " .. entryNode:getID() );

        propagateDamage( entryNode, damage, damageType );

        -- Set effects.
        -- TODO handle destroyed nodes
        for _, node in pairs( nodes ) do
            if node:isDestroyed() then
                if node:isVital() then
                    print( string.format( "The attack destroyed vital organ %s and killed the character.", node:getID() ));
                    dead = true;
                elseif node:isVisual() then
                    print( string.format( "The attack destroyed visual organ %s and blinded the character.", node:getID() ));
                    blind = true;
                end
            end
        end
    end

    function self:addBodyPart( bodyPart )
        local index = bodyPart:getIndex();
        assert( not nodes[index], 'ID already used! BodyParts have to be unique.' );
        nodes[index] = bodyPart;
    end

    function self:addConnection( connection )
        edges[#edges + 1] = connection;
    end

    function self:getBodyPart( id )
        return nodes[id];
    end

    function self:isDead()
        return dead;
    end

    function self:isBlind()
        return blind;
    end

    return self;
end

return Body;
