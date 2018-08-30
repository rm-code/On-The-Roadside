---
-- @module PathFinder
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Path = require( 'src.characters.pathfinding.Path' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PathFinder = {}

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
    local distanceX = math.abs( a:getX() - b:getX() )
    local distanceY = math.abs( a:getY() - b:getY() )
    return (distanceX + distanceY) - 0.9 * math.min( distanceX, distanceY )
end

---
-- Calculates the cost of moving to a tile.
-- @tparam  Tile   tile   The tile to calculate a cost for.
-- @tparam  Tile   target The target tile of the path.
-- @tparam  string stance The stance of the creature to search a path for.
-- @treturn number        The calculated movement cost.
--
local function calculateCost( tile, target, stance )
    if tile:hasWorldObject() then
        local worldObject = tile:getWorldObject()
        local interactionCost = worldObject:getInteractionCost( stance )

        -- We never move on the tile that the character wants to interact with.
        if tile == target then
            return interactionCost
        end

        -- Open the object and walk on the tile.
        if worldObject:isOpenable() and not worldObject:isPassable() then
            return interactionCost + tile:getMovementCost( stance )
        end

        -- Climbing ignores the movement cost of the tile the world object is on.
        if worldObject:isClimbable() then
            return interactionCost
        end
    end

    return tile:getMovementCost( stance )
end

---
-- Removes the node with the lowest cost from the open list and returns it.
-- @treturn table The next node in the list.
-- @return     (number) The index in the list.
--
local function getNextNode( openList )
    local index, cost
    for i = 1, #openList do
        if not cost or cost > openList[i].f then
            cost = openList[i].f
            index = i
        end
    end
    return table.remove( openList, index )
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
        return false
    end

    -- We don't allow movement to tiles occupied by other characters.
    if tile:hasCharacter() then
        return false
    end

    if tile:hasWorldObject() then
        local worldObject = tile:getWorldObject()

        -- Openable world objects never block pathfinding.
        if worldObject:isOpenable() then
            return true
        end

        -- Container objects are valid if they are the target of the path.
        if worldObject:doesBlockPathfinding() and worldObject:isContainer() then
            return tile == target
        end

        -- Non-blocking world objects are valid too.
        return not worldObject:doesBlockPathfinding()
    end
    return tile:isPassable()
end

---
-- Adds a node to the closed list.
-- @param closedList (table) The closed list.
-- @param node       (table) The node to add.
--
local function addToCLosedList( closedList, node )
    closedList[#closedList + 1] = node
end

---
-- Traces the closed list from the target to the starting point by going to the
-- parents of each tile in the list.
-- @param endNode (node) The last node in the generated path.
-- @return        (Path) A path object containing tiles to form a path.
--
local function finalizePath( endNode )
    local path = Path()
    path:addNode( endNode.tile, endNode.actualCost )

    -- Build the rest of the path.
    local parent = endNode.parent
    while parent and parent.parent do
        path:addNode( parent.tile, parent.actualCost )
        parent = parent.parent
    end

    return path
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Calculates a path between two tiles by using the A* algorithm.
-- @tparam  Tile   start  The tile to start the pathfinding at.
-- @tparam  Tile   target The target to search for.
-- @tparam  string stance The stance of the creature to search a path for.
-- @treturn Path          The path containing all tiles from the start to the target.
--
function PathFinder.generatePath( start, target, stance )
    local closedList = {}
    local openList = {
        { tile = start, direction = nil, parent = nil, g = 0, f = 0 } -- Starting point.
    }

    -- The currently evaluated node in the graph.
    local current

    while #openList > 0 do
        current = getNextNode( openList )

        -- Update lists.
        addToCLosedList( closedList, current )

        -- Stop if we have found the target.
        if current.tile == target then
            break;
        end

        -- Look for the next tile.
        for direction, tile in pairs( current.tile:getNeighbours() ) do
            -- Check if the tile is valid to use in our path.
            if isValidTile( tile, closedList, target ) then
                local cost = calculateCost( tile, target, stance )
                local g = current.g + cost
                local f = g + calculateHeuristic( tile, target )

                -- Check if the tile is in the open list. If it is not, then
                -- add it to the open list and proceed. If it already is in
                -- the open list, update its cost and parent values.
                local visitedNode = isInList( openList, tile )
                if not visitedNode then
                    openList[#openList + 1] = { tile = tile, direction = direction, parent = current, actualCost = cost, g = g, f = f }
                elseif g < visitedNode.g then
                    visitedNode.direction = direction
                    visitedNode.parent = current
                    visitedNode.g = g
                    visitedNode.f = f
                end
            end
        end
    end

    return finalizePath( current, stance )
end

return PathFinder
