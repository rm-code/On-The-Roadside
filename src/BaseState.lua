---
-- @module BaseState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local MapLoader = require( 'src.map.MapLoader' )
local Factions = require( 'src.characters.Factions' )
local Inventory = require( 'src.inventory.Inventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseState = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEIGHT_LIMIT = 1000000
local VOLUME_LIMIT = 1000000

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BaseState.new()
    local self = Object.new():addInstance( 'BaseState' )

    local map
    local factions
    local baseInventory

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( playerFaction, savegame )

        map = MapLoader.create( 'base' )
        map:init()

        factions = Factions.new( map )
        factions:addFaction( playerFaction )

        -- Spawn the characters on the map.
        playerFaction:spawnCharacters( map )

        -- Generate initial FOV for all factions.
        playerFaction:iterate( function( character )
            character:generateFOV()
        end)

        baseInventory = Inventory.new( WEIGHT_LIMIT, VOLUME_LIMIT )
        if savegame then
            baseInventory:loadItems( savegame.baseInventory )
        end

        -- Free memory if possible.
        collectgarbage( 'collect' )
    end

    function self:serialize()
        local t = {
            ['type'] = 'base',
            ['factions'] = factions:serialize(),
            ['baseInventory'] = baseInventory:serialize()
        };
        return t;
    end

    function self:update()
        map:update()
    end

    function self:getMap()
        return map
    end

    function self:getFactions()
        return factions
    end

    function self:getCurrentCharacter()
        return factions:getFaction():getCurrentCharacter()
    end

    function self:getBaseInventory()
        return baseInventory
    end

    return self
end

return BaseState
