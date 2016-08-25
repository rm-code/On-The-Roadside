local Object = require( 'src.Object' );
local Inventory = require( 'src.inventory.Inventory' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tile = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new instance of the Tile class.
-- @param x        (number) The grid position along the x-axis.
-- @param y        (number) The grid position along the y-axis.
-- @param template (table)  The tile's template.
-- @return         (Tile)   The new tile.
--
function Tile.new( x, y, template )
    local self = Object.new():addInstance( 'Tile' );

    local name = template.name;
    local type = template.type;
    local movementCost = template.movementCost;
    local passable = template.passable;
    local sprite = template.sprite;
    local color = template.color;

    local id;
    local dirty;
    local neighbours;
    local character;
    local worldObject;
    local inventory = Inventory.new();

    local explored = {};

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds a character to this tile and marks the tile for updating.
    -- @param nchar (Character) The character to add.
    --
    function self:addCharacter( nchar )
        character = nchar;
        self:setDirty( true );
    end

    ---
    -- Adds a table containing the neighbouring tiles. Note that some tiles
    -- might be nil.
    -- @param nneighbours (table) A table containing the neighbouring tiles.
    --
    function self:addNeighbours( nneighbours )
        neighbours = nneighbours;
    end

    ---
    -- Adds a world object to this tile.
    -- @param nworldObject (WorldObject) The WorldObject to add.
    --
    function self:addWorldObject( nworldObject )
        worldObject = nworldObject;
        self:setDirty( true );
    end

    ---
    -- Hits the tile with a certain amount of damage. The tile will distribute
    -- the damage to any character or world object which it contains.
    -- @param damage (number) The damage the tile receives.
    --
    function self:hit( damage )
        if self:isOccupied() then
            character:hit( damage );
        elseif self:hasWorldObject() and worldObject:isDestructible() then
            worldObject:damage( damage );
        end
    end

    ---
    -- Removes the character from this tile and marks it for updating.
    --
    function self:removeCharacter()
        character = nil;
        self:setDirty( true );
    end

    ---
    -- Removes the worldObject from this tile and marks it for updating.
    --
    function self:removeWorldObject()
        worldObject = nil;
        self:setDirty( true );
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the character standing on this tile.
    -- @return (Character) The character standing on the tile.
    --
    function self:getCharacter()
        return character;
    end

    ---
    -- Returns a table containing the RGB values for this tile.
    -- @return (table) The table containing the RGB values.
    --
    function self:getColor()
        return color;
    end

    ---
    -- Returns the tile's unique ID.
    -- @return (number) The tile's ID.
    --
    function self:getID()
        return id;
    end

    ---
    -- Returns the cost it takes a character to traverse this tile.
    -- @return (number) The movement cost for this tile.
    --
    function self:getMovementCost()
        return movementCost;
    end

    ---
    -- Returns the tile's name.
    -- @return (string) The tile's name.
    --
    function self:getName()
        return name;
    end

    ---
    -- Returns a table containing this tile's neighbours.
    -- @return (table) A table containing the neighbouring tiles.
    --
    function self:getNeighbours()
        return neighbours;
    end

    ---
    -- Returns the tile's grid position.
    -- @return (number) The tile's position along the x-axis of the grid.
    -- @return (number) The tile's position along the y-axis of the grid.
    --
    function self:getPosition()
        return x, y;
    end

    ---
    -- Gets the tile's inventory.
    -- @return (Inventory) The tile's inventory.
    --
    function self:getInventory()
        return inventory;
    end

    ---
    -- Gets the tile's index on the spritesheet.
    -- @return (number) The sprite index.
    function self:getSprite()
        return sprite;
    end

    ---
    -- Returns the tile's type.
    -- @return (string) The tile's type.
    --
    function self:getType()
        return type;
    end

    ---
    -- Returns the world object located on this tile.
    -- @return (WorldObject) The WorldObject.
    --
    function self:getWorldObject()
        return worldObject;
    end

    ---
    -- Returns the tile's grid position along the x-axis.
    -- @return (number) The tile's position along the x-axis of the grid.
    --
    function self:getX()
        return x;
    end

    ---
    -- Returns the tile's grid position along the y-axis.
    -- @return (number) The tile's position along the y-axis of the grid.
    --
    function self:getY()
        return y;
    end

    ---
    -- Checks if the tile has a world object.
    -- @return (boolean) True if a WorldObject is located on the tile.
    --
    function self:hasWorldObject()
        return worldObject ~= nil;
    end

    ---
    -- Checks if a given tile is adjacent to this tile.
    -- @return (boolean) True if the tiles are adjacent to each other.
    --
    function self:isAdjacent( tile )
        for _, neighbour in pairs( neighbours ) do
            if neighbour == tile then
                return true;
            end
        end
    end

    ---
    -- Checks if the tile is marked for an update.
    -- @return (boolean) True if the tile is dirty.
    --
    function self:isDirty()
        return dirty;
    end

    ---
    -- Checks if the tile has been explored by a faction.
    -- @param  faction (string)  The faction to check for.
    -- @return         (boolean) True if the tile has been explored.
    --
    function self:isExplored( faction )
        return explored[faction];
    end

    ---
    -- Checks if the tile has a character on it.
    -- @return (boolean) True a character is standing on the tile.
    --
    function self:isOccupied()
        return character ~= nil;
    end

    ---
    -- Checks if the tile is passable.
    -- @return (boolean) True if the tile is passable.
    --
    function self:isPassable()
        if passable and self:hasWorldObject() then
            return worldObject:isPassable();
        end
        return passable;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the dirty state of the tile.
    -- @param ndirty (boolean) Wether the tile should be updated or not.
    --
    function self:setDirty( ndirty )
        dirty = ndirty;
    end

    ---
    -- Marks the tile as explored for a specific faction.
    -- @param  faction (string)  The faction to mark the tile for.
    --
    function self:setExplored( faction, nexplored )
        explored[faction] = nexplored;
    end

    ---
    -- Sets the tile's unique ID.
    -- @param nid (number) The tile's new ID.
    --
    function self:setID( nid )
        id = nid;
    end

    return self;
end

return Tile;
