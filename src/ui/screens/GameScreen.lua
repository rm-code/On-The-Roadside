---
-- The game screen is the topmost game screen / state and acts as a parent for
-- all the other parts of the game (such as combat and base views).
--
-- @module GameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameScreen = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen.new()
    local self = Screen.new()

    function self:init()
        ScreenManager.push( 'base' )
    end

    function self:draw()
    end

    function self:update()
    end

    return self
end

return GameScreen
