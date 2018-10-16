---
-- @module Screen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Screen = Class( 'Screen' )

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Function stub.
--
local function null()
    return
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Screen:isActive()
    return self.active
end

function Screen:setActive( activ )
    self.active = activ
end

-- ------------------------------------------------
-- Callback-stubs
-- ------------------------------------------------

Screen.init = null
Screen.close = null
Screen.receive = null
Screen.directorydropped = null
Screen.draw = null
Screen.filedropped = null
Screen.focus = null
Screen.keypressed = null
Screen.keyreleased = null
Screen.lowmemory = null
Screen.mousefocus = null
Screen.mousemoved = null
Screen.mousepressed = null
Screen.mousereleased = null
Screen.mousedragstopped = null
Screen.mousedragstarted = null
Screen.quit = null
Screen.resize = null
Screen.textedited = null
Screen.textinput = null
Screen.threaderror = null
Screen.touchmoved = null
Screen.touchpressed = null
Screen.touchreleased = null
Screen.update = null
Screen.visible = null
Screen.wheelmoved = null
Screen.gamepadaxis = null
Screen.gamepadpressed = null
Screen.gamepadreleased = null
Screen.joystickadded = null
Screen.joystickaxis = null
Screen.joystickhat = null
Screen.joystickpressed = null
Screen.joystickreleased = null
Screen.joystickremoved = null

return Screen
