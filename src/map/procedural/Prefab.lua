-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Prefab = {}

function Prefab.new( name, type )
    local self = {}

    local grid = {}

    function self:getName()
        return name
    end

    function self:getType()
        return type
    end

    function self:setTiles( ntiles )
        grid.tiles = ntiles
    end

    function self:setObjects( nobjects )
        grid.objects = nobjects
    end

    function self:getTiles()
        return grid.tiles
    end

    function self:getObjects()
        return grid.objects
    end

    return self
end

return Prefab
