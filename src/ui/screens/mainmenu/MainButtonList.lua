local Object = require( 'src.Object' );
local Button = require( 'src.ui.elements.Button' );
local ButtonList = require( 'src.ui.elements.ButtonList' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainButtonList = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainButtonList.new()
    local self = Object.new():addInstance( 'MainButtonList' );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local buttonList;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function startNewGame()
        ScreenManager.switch( 'main' );
    end

    local function exitGame()
        love.event.quit();
    end

    local function createButtons()
        buttonList = ButtonList.new();
        buttonList:addButton( Button.new( 'ui_main_menu_new_game', startNewGame ));
        buttonList:addButton( Button.new( 'ui_main_menu_exit', exitGame ));

        local x = love.graphics.getWidth() * 0.5 - buttonList:getWidth() * 0.5;
        local y = 36 * 16;

        buttonList:setPosition( x, y );
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        createButtons();
    end

    function self:update()
        buttonList:update();
    end

    function self:draw()
        buttonList:draw();
    end

    function self:keypressed( _, scancode )
        buttonList:keypressed( _, scancode );
    end

    function self:mousemoved()
        buttonList:activateMouse();
    end

    function self:mousereleased()
        buttonList:mousereleased();
    end

    return self;
end

return MainButtonList;
