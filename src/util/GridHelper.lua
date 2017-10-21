---
-- @module GridHelper
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GridHelper = {}

function GridHelper.getScreenGridDimensions()
    local tw, th = TexturePacks.getTileDimensions()
    local sw, sh = love.graphics.getDimensions()
    return math.floor( sw / tw ), math.floor( sh / th )
end

return GridHelper
