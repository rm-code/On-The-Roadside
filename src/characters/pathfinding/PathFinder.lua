local Path = require('src.characters.pathfinding.Path');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' );
local MAX_TILES = 300;
local SQRT = math.sqrt( 2 );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PathFinder = {};

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Calculates the heuristic between tiles a and b.
-- @param a (Tile)   The origin.
-- @param b (Tile)   The target.
-- @return  (number) The calculated heuristic.
--
local function calculateHeuristic( a, b )
    local distanceX = math.abs( a:getX() - b:getX() );
    local distanceY = math.abs( a:getY() - b:getY() );
    return math.max( distanceX, distanceY );
end

---
-- Use a modifier for diagonal movement.
-- @param direction (string) The direction to get the modifier for.
-- @return          (number) The modifier.
--
local function getDirectionModifier( direction )
    if direction == DIRECTION.NORTH_EAST
    or direction == DIRECTION.NORTH_WEST
    or direction == DIRECTION.SOUTH_EAST
    or direction == DIRECTION.SOUTH_WEST then
        return SQRT;
    end
    return 1;
end

---
-- Calculates the cost of moving to a tile.
-- @param tile      (Tile)      The tile to calculate a cost for.
-- @param target    (Tile)      The target tile of the path.
-- @param character (Character) The character to plot a path for.
-- @return     (number) The calculated movement cost.
--
local function calculateCost( tile, target, character )
    if tile:hasWorldObject() then
        local worldObject = tile:getWorldObject();
        local interactionCost = worldObject:getInteractionCost( character:getStance() );

        -- We never move on the tile that the character wants to interact with.
        if tile == target then
            return interactionCost;
        end

        -- Open the object and walk on the tile.
        if worldObject:isOpenable() and not worldObject:isPassable() then
            return interactionCost + tile:getMovementCost( character:getStance() );
        end

        -- Climbing ignores the movement cost of the tile the world object is on.
        if worldObject:isClimbable() then
            return interactionCost;
        end
    end

    return tile:getMovementCost( character:getStance() );
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
    for i = 1, #list do
        if list[i].tile == tile then
            return list[i]
        end
    end
    return false
end

---
-- Checks if a tile is valid for pathfinding.
-- @param tile       (Tile)    The tile to check list.
-- @param closedList (table)   The closed list.
-- @param target     (Tile)    The target tile.
-- @return           (boolean) True if the tile can be used for pathfinding.
--
local function isValidTile( tile, closedList, target )
    -- Ignore tiles that are already used in the path.
    if isInList( closedList, tile ) then
        return false;
    end

    -- We don't allow movement to tiles occupied by other characters.
    if tile:isOccupied() then
        return false;
    end

    if tile:hasWorldObject() then
        local worldObject = tile:getWorldObject();

        -- Openable world objects never block pathfinding.
        if worldObject:isOpenable() then
            return true;
        end

        -- Container objects are valid if they are the target of the path.
        if worldObject:blocksPathfinding() and worldObject:isContainer() then
            return tile == target;
        end

        -- Non-blocking world objects are valid too.
        return not worldObject:blocksPathfinding();
    end
    return tile:isPassable();
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
-- @param endNode (node) The last node in the generated path.
-- @return        (Path) A path object containing tiles to form a path.
--
local function finalizePath( endNode )
    local path = Path.new();
    path:addNode( endNode.tile, endNode.actualCost );

    -- Build the rest of the path.
    local parent = endNode.parent;
    while parent and parent.parent do
        path:addNode( parent.tile, parent.actualCost );
        parent = parent.parent;
    end

    return path;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Calculates a path between two tiles by using the A* algorithm.
-- @param character (Character) The character to plot a path for.
-- @param target    (Tile)      The target.
-- @return          (Path)      A Path object containing tiles to form a path.
--
function PathFinder.generatePath( character, target )
    local counter = 0;
    local closedList = {};
    local openList = {
        { tile = character:getTile(), direction = nil, parent = nil, g = 0, f = 0 } -- Starting point.
    };

    while #openList > 0 do
        counter = counter + 1;
        local current, index = getNextTile( openList );

        -- Update lists.
        addToCLosedList( closedList, current );
        removeFromOpenList( openList, index );

        -- Stop if we have found the target.
        if current.tile == target then
            return finalizePath( current, character );
        elseif counter > MAX_TILES then
            return; -- Abort if we haven't found the tile after searching for a while.
        end

        -- Look for the next tile.
        for direction, tile in pairs( current.tile:getNeighbours() ) do
            -- Check if the tile is valid to use in our path.
            if isValidTile( tile, closedList, target ) then
                local cost = calculateCost( tile, target, character );
                local g = current.g + cost * getDirectionModifier( direction );
                local f = g + calculateHeuristic( tile, target );

                -- Check if the tile is in the open list. If it is not, then
                -- add it to the open list and proceed. If it already is in
                -- the open list, update its cost and parent values.
                local visitedNode = isInList( openList, tile );
                if not visitedNode then
                    openList[#openList + 1] = { tile = tile, direction = direction, parent = current, actualCost = cost, g = g, f = f };
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
