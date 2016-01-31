local ScreenManager = require('lib.screenmanager.ScreenManager');

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load()
    print("===================")
    print(string.format("Title: '%s'", getTitle()));
    print(string.format("Version: %.4d", getVersion()));
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
    };

    ScreenManager.init(screens, 'main');
end

function love.draw()
    ScreenManager.draw();
end

function love.update(dt)
    ScreenManager.update(dt);
end

function love.quit(q)
    ScreenManager.quit(q);
end

function love.keypressed(key)
    ScreenManager.keypressed(key);
end

function love.mousepressed( mx, my, button, isTouch )
    ScreenManager.mousepressed( mx, my, button, isTouch );
end
