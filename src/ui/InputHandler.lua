local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );
local LEFT_CLICK  = 1;
local RIGHT_CLICK = 2;

local INPUT_MAP = {
    ['space']  = function() Messenger.publish( 'SWITCH_CHARACTERS'   ) end,
    ['return'] = function() Messenger.publish( 'SWITCH_FACTION'      ) end,
    ['a']      = function() Messenger.publish( 'ENTER_ATTACK_MODE'   ) end,
    ['escape'] = function() Messenger.publish( 'ENTER_MOVEMENT_MODE' ) end,
    ['right']  = function() Messenger.publish( 'NEXT_FIRING_MODE'    ) end,
    ['left']   = function() Messenger.publish( 'PREV_FIRING_MODE'    ) end
};

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InputHandler = {};

function InputHandler.new( game )
    local self = {};

    love.mouse.setVisible( false );
    love.mouse.setGrabbed( true );
    love.mouse.setPosition( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 );

    local map = game:getMap();
    local mouseX, mouseY = 0, 0;

    local blocked = false;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        local mx, my = love.mouse.getPosition();
        local tx, ty = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );

        if mouseX ~= tx or mouseY ~= ty then
            mouseX, mouseY = tx, ty;
            Messenger.publish( 'MOUSE_MOVED', mouseX, mouseY );
        end
    end

    function self:keypressed( key )
        local action = INPUT_MAP[key];
        if action then
            action();
        end
    end

    function self:mousepressed( _, _, button )
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile or blocked then
            return;
        end

        if button == LEFT_CLICK then
            Messenger.publish( 'LEFT_CLICKED_TILE', tile );
        elseif button == RIGHT_CLICK then
            Messenger.publish( 'RIGHT_CLICKED_TILE', tile );
        end
    end

    Messenger.observe( 'DISABLE_INPUT', function()
        blocked = true;
    end)

    Messenger.observe( 'ENABLE_INPUT', function()
        blocked = false;
    end)

    return self;
end

return InputHandler;
