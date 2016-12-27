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

    local function selectEntryNode()
        local entryNodes = {};
        for _, node in pairs( nodes ) do
            if node:isEntryNode() then
                entryNodes[#entryNodes + 1] = node;
            end
        end
        return entryNodes[love.math.random( #entryNodes )];
    end

    local function getConnectedNodes( origin )
        local tmp = {};

        -- Find all nodes connected to the original node.
        for _, edge in ipairs( edges ) do

            if edge.from == origin then
                print( string.format( "Chance that damage propagates from %s to %s was %d%%.", nodes[edge.from]:getID(), nodes[edge.to]:getID(), edge.name ));

                local rnd = love.math.random( 100 );
                if rnd < edge.name then
                    print( string.format( "  -> Rolled a %d", rnd ));
                    tmp[#tmp + 1] = nodes[edge.to];
                end
            end
        end

        return tmp;
    end

    local function propagateDamage( node, damage, damageType )
        node:hit( damage, damageType );

        local connectedNodes = getConnectedNodes( node:getIndex() );
        for _, n in ipairs( connectedNodes ) do
            propagateDamage( n, damage, damageType );
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
        for _, node in pairs( nodes ) do
            if node:isDestroyed() then
                if node:isVital() then
                    print( string.format( "The attack destroyed vital organ %s and killed the character.", node:getID() ));
                    dead = true;
                elseif node:isVisual() then
                    print( string.format( "The attack destroyed visual organ %s and blinded the character.", node:getID() ));
                    blind = true;
                elseif node:isContainer() then
                    print( string.format( "The attack destroyed container organ %s and all contained organs.", node:getID() ));
                    for _, n in ipairs( getConnectedNodes( node:getIndex() )) do
                        n:setHealth( 0 );
                    end
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
