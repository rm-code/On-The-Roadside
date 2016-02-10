local PathFinder = {};

---
-- Calculates the heuristic between tiles a and b.
-- @param a (Tile)   The origin.
-- @param b (Tile)   The target.
-- @return  (number) The calculated heuristic.
--
local function calculateHeuristic( a, b )
    local distanceX = math.abs( a:getX() - b:getX() );
    local distanceY = math.abs( a:getY() - b:getY() );
    if distanceX > distanceY then
        return 1.414 * distanceY + ( distanceX - distanceY );
    else
        return 1.414 * distanceX + ( distanceY - distanceX );
    end
end

---
-- Gets the next tile with the lowest cost from a list.
-- @param list (table)  The list to search through.
-- @return     (table)  The next tile in the list.
-- @return     (number) The index in the list.
--
local function getNextTile( list )
    local index, cost;
    for i = 1, #list do
        if not cost or cost > list[i].f then
            cost = list[i].f;
            index = i;
        end
    end
    return list[index], index;
end

---
-- Checks if a tile is in a list and returns the A* node containing the tile.
-- @param list   (table)   The list to search in.
-- @param tile   (Tile)    The tile to find in the list.
-- @param return (boolean) Wether the tile is in the list or not.
--
local function isInList( list, tile )
    for _, node in ipairs( list ) do
        if node.tile == tile then
            return node;
        end
    end
    return false;
end

---
-- Adds a node to the closed list.
-- @param closedList (table) The closed list.
-- @param node       (table) The node to add.
--
local function addToCLosedList( closedList, node )
    closedList[#closedList + 1] = node;
end

---
-- Removes a node from the open list.
-- @param openList (table)  The open list.
-- @param index    (number) The index of the node to remove.
--
local function removeFromOpenList( openList, index )
    table.remove( openList, index );
end

---
-- Traces the closed list from the target to the starting point by going to the
-- parents of each tile in the list.
-- @param endNode (node)  The last node in the generated path.
-- @result        (table) A sequence containing directions to form a path.
--
local function finalizePath( endNode )
    local result, parent = { endNode.direction }, endNode.parent;
    while parent and parent.direction do
        table.insert( result, 1, parent.direction );
        parent = parent.parent;
    end
    return result;
end

---
-- Calculates a path between two tiles by using the A* algorithm.
-- @param origin (Tile)  The origin.
-- @param target (Tile)  The target.
-- @param return (table) A sequence containing directions to form a path.
--
function PathFinder.generatePath( origin, target )
    local closedList = {};
    local openList = {
        { tile = origin, direction = nil, parent = nil, g = 0, f = 0 } -- Starting point.
    };

    while #openList > 0 do
        local current, index = getNextTile( openList );

        -- Update lists.
        addToCLosedList( closedList, current );
        removeFromOpenList( openList, index );

        -- Stop if we have found the target.
        if current.tile == target then
            return finalizePath( current );
        end

        -- Look for the next tile.
        for direction, tile in pairs( current.tile:getNeighbours() ) do
            local g = current.g + 1;
            local f = g + calculateHeuristic( tile, target );

            -- Check if the tile is passable and not in the closed list or if the
            -- tile is the target we are looking for.
            if ( tile:getWorldObject():isPassable() and not tile:isOccupied() and not isInList( closedList, tile )) or tile == target then
                -- Check if the tile is in the open list. If it is not, then
                -- add it to the open list and proceed. If it already is in
                -- the open list, update its cost and parent values.
                local visitedNode = isInList( openList, tile );
                if not visitedNode then
                    openList[#openList + 1] = { tile = tile, direction = direction, parent = current, g = g, f = f };
                elseif g < visitedNode.g then
                    visitedNode.direction = direction;
                    visitedNode.parent = current;
                    visitedNode.g = g;
                    visitedNode.f = f;
                end
            end
        end
    end
end

return PathFinder;
