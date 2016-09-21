local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local ItemFactory = require( 'src.items.ItemFactory' );
local CharacterFactory = require( 'src.characters.CharacterFactory' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SaveHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local loadstring = loadstring and loadstring or load; -- Lua 5.1+ compatibility.

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function serialize( value, output, depth )
    local ws = '    ';
    for _ = 1, depth do
        ws = ws .. '    ';
    end
    if type( value ) == 'table' then
        for k, v in pairs(value) do
            if type( v ) == 'table' then
                table.insert( output, string.format( '%s[\'%s\'] = {', ws, tostring( k )));
                serialize( v, output, depth + 1 );
                table.insert( output, string.format( '%s},', ws ));
            elseif type( v ) == 'string' then
                table.insert( output, string.format( '%s[\'%s\'] = "%s",', ws, tostring( k ), tostring( v )));
            else
                table.insert( output, string.format( '%s[\'%s\'] = %s,', ws, tostring( k ), tostring( v )));
            end
        end
    else
        table.insert( output, string.format( '%s%s,', tostring( value )));
    end
end

local function cleanup( value )
    for k, v in pairs( value ) do
        -- If the key can be transformed into a number delete the original
        -- key-value pair and store the value with the numerical key.
        if tonumber( k ) then
            value[k] = nil;
            value[tonumber(k)] = v;
        end

        if type( v ) == 'table' then
            cleanup( v );
        elseif tonumber( v ) then
            value[k] = tonumber( v );
        end
    end
    return value;
end

local function loadFile()
    local compressed, bytes = love.filesystem.read( 'compressed.data' );
    print( string.format( 'Loaded SaveHandler (Size: %d bytes)', bytes ));

    local decompressed = love.math.decompress( compressed, 'lz4' );
    local rawsave = loadstring( decompressed )();
    return cleanup( rawsave );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function SaveHandler.save( t )
    local output = {};
    table.insert( output, 'return {' );
    serialize( t, output, 0 )
    table.insert( output, '}' );

    local str = table.concat( output, '\n' );
    local compress = love.math.compress( str, 'lz4', 9 );
    love.filesystem.write( 'compressed.data', compress );
end

function SaveHandler.load()
    local self = {};

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local save = loadFile();

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function createMagazine( item )
        local magazine = ItemFactory.createItem( item.itemType, item.id, item );
        magazine:setRounds( item.rounds );
        magazine:setCapacity( item.capacity );

        return magazine;
    end

    local function createWeapon( item )
        local weapon = ItemFactory.createItem( item.itemType, item.id );
        weapon:setAttackMode( item.modeIndex );

        if weapon:getWeaponType() ~= 'Melee' and weapon:getWeaponType() ~= 'Grenade' then
            local magazine = createMagazine( item.magazine );
            weapon:reload( magazine );
        end

        return weapon;
    end

    local function fillInventory( source, target )
        for _, item in pairs( source ) do
            if item.itemType == ITEM_TYPES.WEAPON then
                local weapon = createWeapon( item );
                target:addItem( weapon );
            elseif item.itemType == ITEM_TYPES.BAG then
                local bag = ItemFactory.createItem( item.itemType, item.id );
                fillInventory( item.inventory, bag:getInventory() );
                target:addItem( bag )
            elseif item.itemType == ITEM_TYPES.AMMO then
                local ammo = createMagazine( item );
                target:addItem( ammo );
            elseif item.itemType == ITEM_TYPES.HEADGEAR then
                local headgear = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( headgear );
            elseif item.itemType == ITEM_TYPES.GLOVES then
                local gloves = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( gloves );
            elseif item.itemType == ITEM_TYPES.JACKET then
                local jacket = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( jacket );
            elseif item.itemType == ITEM_TYPES.SHIRT then
                local shirt = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( shirt );
            elseif item.itemType == ITEM_TYPES.TROUSERS then
                local trousers = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( trousers );
            elseif item.itemType == ITEM_TYPES.FOOTWEAR then
                local footwear = ItemFactory.createItem( item.itemType, item.id );
                target:addItem( footwear );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:loadMap( map )
        local loadedTiles = {};
        for _, tile in ipairs( save ) do
            local x, y = tile.x, tile.y;
            loadedTiles[x] = loadedTiles[x] or {};
            loadedTiles[x][y] = TileFactory.create( x, y, tile.id );
            local newTile = loadedTiles[x][y];

            if tile.worldObject then
                local worldObject = WorldObjectFactory.create( tile.worldObject.id );
                worldObject:setHitPoints( tile.worldObject.hp );
                worldObject:setPassable( tile.worldObject.passable );
                worldObject:setBlocksVision( tile.worldObject.blocksVision );
                if worldObject:isContainer() and tile.worldObject.inventory then
                    fillInventory( tile.worldObject.inventory, worldObject:getInventory() );
                end
                newTile:addWorldObject( worldObject );
            end
            if tile.inventory then
                fillInventory( tile.inventory, newTile:getInventory() );
            end
            if tile.explored then
                for i, v in pairs( tile.explored ) do
                    newTile:setExplored( i, v );
                end
            end
        end
        map:recreate( loadedTiles );
    end

    function self:loadCharacters( map, factions )
        for _, tile in ipairs( save ) do
            if tile.character then
                local faction = factions:findFaction( tile.character.faction );
                local character = CharacterFactory.loadCharacter( map, map:getTileAt( tile.x, tile.y ), faction );
                character:setActionPoints( tile.character.ap );
                character:setHealth( tile.character.health );
                character:setAccuracy( tile.character.accuracy );
                character:setStance( tile.character.stance );

                if tile.character.inventory then
                    fillInventory( tile.character.inventory, character:getInventory() );
                end

                factions:addCharacter( character );
            end
        end
    end

    return self;
end

function SaveHandler.hasSaveFile()
    return love.filesystem.exists( 'compressed.data' );
end

return SaveHandler;
