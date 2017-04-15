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
local Faction = require( 'src.characters.Faction' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseState = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )
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

    function self:init()
        map = MapLoader.create( 'base' )
        map:init()

        factions = Factions.new( map )
        factions:addFaction( Faction.new( FACTIONS.ALLIED, false ))
        factions:findFaction( FACTIONS.ALLIED ):addCharacters( 10, 'human' )
        factions:findFaction( FACTIONS.ALLIED ):spawnCharacters( map )

        -- Generate initial FOV for all factions.
        factions:iterate( function( faction )
            faction:iterate( function( character )
                character:generateFOV()
            end)
        end)

        baseInventory = Inventory.new( WEIGHT_LIMIT, VOLUME_LIMIT )

        -- Free memory if possible.
        collectgarbage( 'collect' )
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
