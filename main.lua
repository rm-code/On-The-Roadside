local ScreenManager = require('lib.screenmanager.ScreenManager');
local ProFi = require( 'lib.ProFi' );
local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

-- TODO Remove profiling code.
local profile = 0;
local info;

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load()
    Log.init();

    info = {};
    info[#info + 1] = "===================";
    info[#info + 1] = string.format( "Title: '%s'", getTitle() );
    info[#info + 1] = string.format( "Version: %s", getVersion() );
    info[#info + 1] = string.format( "LOVE Version: %d.%d.%d (%s)", love.getVersion() );
    info[#info + 1] = string.format( "Resolution: %dx%d\n", love.graphics.getDimensions() );

    info[#info + 1] = "---- RENDERER  ---- ";
    local name, version, vendor, device = love.graphics.getRendererInfo()
    info[#info + 1] = string.format( "Name: %s \n Version: %s \n Vendor: %s \n Device: %s\n", name, version, vendor, device );
    info[#info + 1] = "-------------------";
    info[#info + 1] = os.date( "%d.%m.%Y %H:%M:%S", os.time() )
    info[#info + 1] = "===================\n";

    for _, line in ipairs( info ) do
        Log.print( line );
    end

    local screens = {
        bootloading = require( 'src.ui.screens.BootLoadingScreen' ),
        mainmenu    = require( 'src.ui.screens.MainMenu'          ),
        basemenu    = require( 'src.ui.screens.IngameBaseMenu'    ),
        ingamemenu  = require( 'src.ui.screens.IngameCombatMenu'  ),
        options     = require( 'src.ui.screens.OptionsScreen'     ),
        base        = require( 'src.ui.screens.BaseScreen'        ),
        combat      = require( 'src.ui.screens.CombatScreen'      ),
        inventory   = require( 'src.ui.screens.InventoryScreen'   ),
        help        = require( 'src.ui.screens.HelpScreen'        ),
        health      = require( 'src.ui.screens.HealthScreen'      ),
        gamescreen  = require( 'src.ui.screens.GameScreen'        ),
        gameover    = require( 'src.ui.screens.GameOverScreen'    ),
        loadgame    = require( 'src.ui.screens.SavegameScreen'    )
    };

    ScreenManager.init( screens, 'bootloading' );
end

function love.draw()
    if profile == 2 then
        ProFi:start();
    end

    ScreenManager.draw();

    if profile == 2 then
        ProFi:stop();
        ProFi:writeReport( string.format( '../profiling/draw_%d.txt', os.time( os.date( '*t' ))));
        profile = 0;
    end
end

function love.update(dt)
    if profile == 1 then
        ProFi:start();
    end

    ScreenManager.update(dt);

    if profile == 1 then
        ProFi:stop();
        local success = ProFi:writeReport( string.format( '../profiling/update_%d.txt', os.time( os.date( '*t' ))));
        profile = success and 2 or 0;
    end
end

function love.quit(q)
    ScreenManager.quit(q);
end

function love.keypressed( key, scancode, isrepeat )
    ScreenManager.keypressed( key, scancode, isrepeat );

    if scancode == '0' then
        profile = 1;
    elseif scancode == 'f2' then
        Log.setDebugActive( not Log.getDebugActive() );
    end
end

function love.resize( w, h )
    ScreenManager.resize( w, h );
end

function love.mousepressed( mx, my, button, isTouch )
    ScreenManager.mousepressed( mx, my, button, isTouch );
end

function love.mousereleased( mx, my, button, isTouch )
    ScreenManager.mousereleased( mx, my, button, isTouch );
end

function love.mousefocus( f )
    ScreenManager.mousefocus( f );
end

function love.mousemoved( x, y, dx, dy, isTouch )
    ScreenManager.mousemoved( x, y, dx, dy, isTouch );
end

function love.errhand( msg )
    msg = tostring( msg );

    Log.error(( debug.traceback( tostring( msg ), 3 ):gsub( "\n[^\n]+$", "" )));

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
    table.insert(err, 'Press <return> to open the directoy.' )

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

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
                end
                return
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
