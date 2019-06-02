---
-- Takes care of drawing the large ASCII titles used in different menus.
-- @module UIMenuTitle
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIMenuTitle = Class( 'UIMenuTitle' )

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Iterates over the title definition and creates a text object containing the
-- colored lines.
-- @tparam  table titleDefinition The table containing all lines to be processed.
-- @treturn Text                  The drawable text object containing the assembled title.
--
local function createTitle( titleDefinition )
    local font = TexturePacks.getFont():get()
    local title = love.graphics.newText( font )
    local coloredtext = {}

    for w in string.gmatch( titleDefinition, '.' ) do
        if w == 'O' then
            coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_1' )
            coloredtext[#coloredtext + 1] = w
        elseif w == '!' then
            coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_2' )
            coloredtext[#coloredtext + 1] = w
        elseif w == ':' then
            coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_3' )
            coloredtext[#coloredtext + 1] = w
        else
            coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_0' )
            coloredtext[#coloredtext + 1] = w
        end
    end

    title:add( coloredtext, 0, 0 )
    return title
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIMenuTitle:initialize( titleDefinition, y )
    self.title = createTitle( titleDefinition )
    self.y = y
end

function UIMenuTitle:draw()
    local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( self.title:getWidth(), 0 ))
    local tw, _ = TexturePacks.getTileDimensions()
    love.graphics.draw( self.title, cx * tw, self.y * TexturePacks.getFont():getGlyphHeight() )
end

return UIMenuTitle
