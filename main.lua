local ScreenManager = require('lib.screenmanager.ScreenManager')
local Log = require( 'src.util.Log' )
local DebugGrid = require( 'src.ui.overlays.DebugGrid' )
local Letterbox = require( 'src.ui.overlays.Letterbox' )
local DataHandler = require( 'src.DataHandler' )

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local debugGrid
local letterbox

local mousepressed = false
local mousedragged = false

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEBUG_OUTPUT_FLAG     = '-d'
local DEBUG_GRID_FLAG       = '-g'
local DEBUG_FULLSCREEN_FLAG = '-f'
local DEBUG_WINDOWED_FLAG   = '-w'

local SCREENS = {
    bootloading      = require( 'src.ui.screens.BootLoadingScreen'     ),
    mainmenu         = require( 'src.ui.screens.MainMenu'              ),
    ingamemenu       = require( 'src.ui.screens.IngameCombatMenu'      ),
    options          = require( 'src.ui.screens.OptionsScreen'         ),
    changelog        = require( 'src.ui.screens.ChangelogScreen'       ),
    combat           = require( 'src.ui.screens.CombatScreen'          ),
    inventory        = require( 'src.ui.screens.InventoryScreen'       ),
    help             = require( 'src.ui.screens.HelpScreen'            ),
    gamescreen       = require( 'src.ui.screens.GameScreen'            ),
    gameover         = require( 'src.ui.screens.GameOverScreen'        ),
    loadgame         = require( 'src.ui.screens.SavegameScreen'        ),
    confirm          = require( 'src.ui.screens.ConfirmationModal'     ),
    information      = require( 'src.ui.screens.InformationModal'      ),
    inputdialog      = require( 'src.ui.screens.InputDialog'           ),
    maptest          = require( 'src.ui.screens.MapTest'               ),
    mapeditor        = require( 'src.map.editor.MapEditor'             ),
    mapeditormenu    = require( 'src.map.editor.MapEditorMenu'         ),
    prefabeditor     = require( 'src.map.editor.PrefabEditor'          ),
    prefabeditormenu = require( 'src.map.editor.PrefabEditorMenu'      ),
    editorloading    = require( 'src.map.editor.EditorLoadingScreen'   ),
    keybindingeditor = require( 'src.ui.screens.KeybindingScreen'      ),
    keybindingmodal  = require( 'src.ui.screens.KeybindingModal'       ),
    playerInfo       = require( 'src.ui.screens.PlayerInfo'            ),
    base             = require( 'src.base.BaseScreen'                  ),
    basemenu         = require( 'src.base.BaseScreenMenu'              ),
    recruitment      = require( 'src.base.RecruitmentScreen'           ),
    shop             = require( 'src.base.ShopScreen'                  ),
}

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Iterates over any provided command line arguments and activates the proper
-- mechanics.
--
local function handleCommandLineArguments( args )
    for _, arg in pairs( args ) do
        if arg == DEBUG_OUTPUT_FLAG then
            Log.setDebugActive( true )
        elseif arg == DEBUG_GRID_FLAG then
            debugGrid = true
        elseif arg == DEBUG_FULLSCREEN_FLAG then
            love.window.setFullscreen( true )
        elseif arg == DEBUG_WINDOWED_FLAG then
            love.window.setFullscreen( false )
        end
    end
end

---
-- Prints some information about the game and the player's system.
--
local function printGameInfo()
    local info = {}
    info[#info + 1] = "==================="
    info[#info + 1] = string.format( "Title: '%s'", getTitle() )
    info[#info + 1] = string.format( "Version: %s", getVersion() )
    info[#info + 1] = string.format( "LOVE Version: %d.%d.%d (%s)", love.getVersion() )
    info[#info + 1] = string.format( "OS: %s", love.system.getOS() )
    info[#info + 1] = string.format( "Resolution: %dx%d\n", love.graphics.getDimensions() )

    info[#info + 1] = "---- RENDERER  ---- "
    local name, version, vendor, device = love.graphics.getRendererInfo()
    info[#info + 1] = string.format( "Name: %s \n Version: %s \n Vendor: %s \n Device: %s\n", name, version, vendor, device )
    info[#info + 1] = "-------------------"
    info[#info + 1] = os.date( "%d.%m.%Y %H:%M:%S", os.time() )
    info[#info + 1] = "===================\n"

    for _, line in ipairs( info ) do
        Log.print( line )
    end
end

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load( args )
    Log.init()

    handleCommandLineArguments( args )

    printGameInfo()

    ScreenManager.init( SCREENS, 'bootloading' )

    letterbox = Letterbox()

    -- Create the actual debug grid, if the debug grid flag was set via command
    -- line arguments.
    if debugGrid then
        debugGrid = DebugGrid()
    end
end

function love.draw()
    ScreenManager.draw()

    if debugGrid then
        debugGrid:draw()
    end

    letterbox.draw()
end

function love.update(dt)
    ScreenManager.update(dt)
end

function love.quit(q)
    Log.info( 'Shutting down...', 'Main' )

    ScreenManager.quit(q)

    DataHandler.removeTemporaryFiles()
    Log.info( 'Thank you for playing "On The Roadside"!', 'Main' )
end

function love.keypressed( key, scancode, isrepeat )
    ScreenManager.keypressed( key, scancode, isrepeat )
end

function love.keyreleased( key, scancode )
    ScreenManager.keyreleased( key, scancode )
end

function love.resize( w, h )
    ScreenManager.resize( w, h )
end

function love.textinput( text )
    ScreenManager.textinput( text )
end

function love.mousepressed( mx, my, button, isTouch, presses )
    mousepressed = true
    ScreenManager.mousepressed( mx, my, button, isTouch, presses )
end

function love.mousereleased( mx, my, button, isTouch, presses )
    mousepressed = false
    if mousedragged then
        mousedragged = false
        ScreenManager.mousedragstopped()
        return
    end

    ScreenManager.mousereleased( mx, my, button, isTouch, presses )
end

function love.mousefocus( f )
    ScreenManager.mousefocus( f )
end

function love.mousemoved( x, y, dx, dy, isTouch )
    if mousepressed then
        mousedragged = true
        mousepressed = false
        ScreenManager.mousedragstarted()
    end

    ScreenManager.mousemoved( x, y, dx, dy, isTouch )
end

function love.wheelmoved( dx, dy )
    ScreenManager.wheelmoved( dx, dy )
end

function love.errhand( msg )
    msg = tostring( msg )

    Log.error(( debug.traceback( tostring( msg ), 3 ):gsub( "\n[^\n]+$", "" )))

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for _,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

    love.graphics.setBackgroundColor( 0, 0, 0, 0 )
    love.graphics.setColor( 255, 255, 255, 255 )

    local trace = debug.traceback()

    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()

    local err = {}

    table.insert(err, "\n\nError\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    table.insert(err, '\n\nYou can find the error in the latest.log file in your save directory.' )
    table.insert(err, 'Press <return> to open the directoy. Press <escape> to close the game.' )

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    -- Save a copy of the log to the crash dump folder.
    Log.saveCrashDump()

    local function draw()
        local pos = love.window.toPixels(70)
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        love.graphics.present()
    end

    while true do
        love.event.pump()
        for e, a, _, _ in love.event.poll() do
            if e == "quit" then
                return
            elseif e == "keypressed" then
                if a == "return" then
                    love.system.openURL( 'file://' .. love.filesystem.getSaveDirectory() )
                    return
                elseif a == "escape" then
                    return
                end
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = {"OK", "Cancel"}
                local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
                if pressed == 1 then
                    return
                end
            end
        end
        draw()
        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end
