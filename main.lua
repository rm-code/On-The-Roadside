local ScreenManager = require('lib.screenmanager.ScreenManager');
local ProFi = require( 'lib.ProFi' );

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

-- TODO Remove profiling code.
local profile = 0;

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load()
    print("===================")
    print(string.format("Title: '%s'", getTitle()));
    print(string.format("Version: %s", getVersion()));
    print(string.format("LOVE Version: %d.%d.%d (%s)", love.getVersion()));
    print(string.format("Resolution: %dx%d", love.graphics.getDimensions()));

    print("\n---- RENDERER  ---- ");
    local name, version, vendor, device = love.graphics.getRendererInfo()
    print(string.format("Name: %s \nVersion: %s \nVendor: %s \nDevice: %s", name, version, vendor, device));

    print("===================")
    print(os.date('%c', os.time()));
    print("===================")

    local screens = {
        main = require('src.screens.MainScreen');
        inventory = require('src.screens.InventoryScreen');
    };

    ScreenManager.init(screens, 'main');
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

function love.keypressed(key)
    ScreenManager.keypressed(key);

    if key == '0' then
        profile = 1;
    end
end

function love.mousepressed( mx, my, button, isTouch )
    ScreenManager.mousepressed( mx, my, button, isTouch );
end

function love.mousefocus( f )
    ScreenManager.mousefocus( f );
end
