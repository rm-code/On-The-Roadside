local CharacterManager = require( 'src.characters.CharacterManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

local COLORS = require( 'src.constants.Colors' );
local FACTIONS = require( 'src.constants.Factions' );

local CHARACTER_COLORS = {
    ACTIVE = {
        [FACTIONS.ALLIED]  = COLORS.DB17,
        [FACTIONS.NEUTRAL] = COLORS.DB09,
        [FACTIONS.ENEMY]   = COLORS.DB05
    },
    INACTIVE = {
        [FACTIONS.ALLIED]  = COLORS.DB15,
        [FACTIONS.NEUTRAL] = COLORS.DB12,
        [FACTIONS.ENEMY]   = COLORS.DB27
    }
}

local TILE_SIZE = require( 'src.constants.TileSize' );
local TILESET = love.graphics.newImage( 'res/img/16x16_sm.png' );

local TILE_SPRITES = {};
for x = 1, TILESET:getWidth() / TILE_SIZE do
    for y = 1, TILESET:getHeight() / TILE_SIZE do
        TILE_SPRITES[#TILE_SPRITES + 1] = love.graphics.newQuad(( y - 1 ) * TILE_SIZE, ( x - 1 ) * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    end
end

print( "Loaded " .. #TILE_SPRITES .. " sprites!" );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldPainter = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function WorldPainter.new( game )
    local self = {};

    local spritebatch;

    love.graphics.setPointSize( 4 );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- @param value (number) The cost of the node.
    -- @param total (number) The total number of nodes in the path.
    --
    local function selectPathNodeColor( value, total )
        local fraction = value / total;
        if fraction < 0 then
            return COLORS.DB27;
        elseif fraction <= 0.2 then
            return COLORS.DB05;
        elseif fraction <= 0.6 then
            return COLORS.DB08;
        elseif fraction <= 1.0 then
            return COLORS.DB09;
        end
    end

    local function drawPath( character )
        if #character:getActions() ~= 0 then
            local total = character:getActionPoints();
            local ap = total;

            for _, action in ipairs( character:getActions() ) do
                ap = ap - action:getCost();

                -- Clears the tile.
                local tile = action:getTarget();
                love.graphics.setColor( 0, 0, 0);
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );

                -- Draws the path icon.
                love.graphics.setColor( selectPathNodeColor( ap, character:getMaxActionPoints() ));
                love.graphics.draw( TILESET, TILE_SPRITES[176], tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE );
                love.graphics.setColor( 255, 255, 255);
            end
        end
    end

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each tile a unique identifier and sets it to dirty for the first update.
    -- @param map (Map) The game's world map.
    --
    local function initSpritebatch( map )
        map:iterate( function( tile, x, y )
            local id = spritebatch:add( TILE_SPRITES[1], x * TILE_SIZE, y * TILE_SIZE );
            tile:setID( id );
            tile:setDirty( true );
        end)
        print( string.format('Initialised %d tiles.', spritebatch:getCount()) );
    end

    ---
    -- Selects a color which to use when a tile is drawn based on its contents.
    -- @param tile (Tile)  The tile to choose a color for.
    -- @return     (table) A table containing RGBA values.
    --
    local function selectTileColor( tile )
        -- Hide unexplored tiles.
        if not tile:isExplored() then
            return COLORS.DB00;
        end

        -- Dim tiles hidden from the player.
        if not tile:isVisible() then
            return COLORS.DB01;
        end

        if tile:isOccupied() then
            if tile:getCharacter() == CharacterManager.getCurrentCharacter() then
                return CHARACTER_COLORS.ACTIVE[tile:getCharacter():getFaction()];
            else
                return CHARACTER_COLORS.INACTIVE[tile:getCharacter():getFaction()];
            end
        elseif tile:hasWorldObject() then
            local worldObject = tile:getWorldObject();
            if worldObject:getType() == 'worldobject_door' then
                return COLORS.DB03;
            elseif worldObject:getType() == 'worldobject_wall' then
                return COLORS.DB23;
            elseif worldObject:getType() == 'worldobject_fence' or worldObject:getType() == 'worldobject_fencegate' then
                return COLORS.DB04;
            elseif worldObject:getType() == 'worldobject_chair' then
                return COLORS.DB04;
            elseif worldObject:getType() == 'worldobject_table' then
                return COLORS.DB04;
            elseif worldObject:getType() == 'worldobject_window' then
                return COLORS.DB19;
            elseif worldObject:getType() == 'worldobject_lowwall' then
                return COLORS.DB23;
            end
        elseif not tile:getStorage():isEmpty() then
            return COLORS.DB27;
        else
            if tile:getType() == 'tile_water' then
                return COLORS.DB16;
            elseif tile:getType() == 'tile_deep_water' then
                return COLORS.DB15;
            elseif tile:getType() == 'tile_grass' then
                return COLORS.DB12;
            elseif tile:getType() == 'tile_asphalt' then
                return COLORS.DB25;
            end
            return COLORS.DB03;
        end
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @param tile (Tile) The tile to choose a sprite for.
    -- @return     (Quad) A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile )
        if tile:isOccupied() and tile:isVisible() then
            if tile:getCharacter():getFaction() == FACTIONS.ENEMY then
                return TILE_SPRITES[3];
            else
                return TILE_SPRITES[2];
            end
        end

        if tile:hasWorldObject() then
            return TILE_SPRITES[tile:getWorldObject():getSprite()];
        end

        return TILE_SPRITES[tile:getSprite()];
    end

    ---
    -- Updates the spritebatch by going through every tile in the map. Only
    -- tiles which have been marked as dirty will be sent to the spritebatch.
    -- @param map (Map) The game's world map.
    --
    local function updateSpritebatch( map )
        map:iterate( function( tile, x, y)
            if tile:isDirty() then
                spritebatch:setColor( selectTileColor( tile ) );
                spritebatch:set( tile:getID(), selectTileSprite( tile ), x * TILE_SIZE, y * TILE_SIZE );
                tile:setDirty( false );
            end
        end)
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        love.graphics.setBackgroundColor( COLORS.DB00 );
        spritebatch = love.graphics.newSpriteBatch( TILESET, 10000, 'dynamic' );
        initSpritebatch( game:getMap() );
    end

    function self:draw()
        local character = CharacterManager.getCurrentCharacter();
        love.graphics.draw( spritebatch, 0, 0 );

        -- TODO move to function
        if character:hasLineOfSight() then
            character:getLineOfSight():iterate( function( tile )
                love.graphics.setColor( 0, 255, 0 );
                if not tile:isPassable() or not tile:isVisible() then
                    love.graphics.setColor( 255, 0, 0 );
                end
                love.graphics.rectangle( 'line', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            end)
            love.graphics.setColor( 255, 255, 255 );
        end

        ProjectileManager.iterate( function( x, y )
            love.graphics.points( x * TILE_SIZE, y * TILE_SIZE );
        end)

        drawPath( character );
    end

    function self:update()
        local map = game:getMap();
        for _, char in ipairs( CharacterManager.getCharacters() ) do
            map:calculateVisibility( char:getTile(), char:getViewRange() );
            if char:hasPath() then
                char:getPath():refresh();
            end
        end
        updateSpritebatch( game:getMap() );
    end

    return self;
end

return WorldPainter;
