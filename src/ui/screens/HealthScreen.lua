local Log = require( 'src.util.Log' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Translator = require( 'src.util.Translator' );
local Outlines = require( 'src.ui.elements.Outlines' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HealthScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local SCREEN_WIDTH  = 30;
local SCREEN_HEIGHT = 16;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function HealthScreen.new()
    local self = Screen.new();

    local character;
    local characterType;

    local outlines
    local px, py;
    local tw, th

    local function createOutlines( w, h )
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                -- Draw screen borders.
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    outlines:add( x, y )
                end
                if y == 2 then
                    outlines:add( x, y )
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ncharacter )
        tw, th = TexturePacks.getTileDimensions()

        character = ncharacter;
        characterType = character:getBody():getID();

        px = math.floor( love.graphics.getWidth() / tw ) * 0.5 - math.floor( SCREEN_WIDTH * 0.5 )
        py = math.floor( love.graphics.getHeight() / th ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 )
        px, py = px * tw, py * th

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()
    end

    function self:draw()
        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', px, py, SCREEN_WIDTH * tw, SCREEN_HEIGHT * th )
        love.graphics.setColor( COLORS.DB22 );

        outlines:draw( px, py )

        local counter = 3;
        for _, bodyPart in pairs( character:getBody():getBodyParts() ) do
            if bodyPart:isEntryNode() then
                counter = counter + 1;
                local status;
                if bodyPart:isDestroyed() then
                    love.graphics.setColor( COLORS.DB24 );
                    status = 'DED'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.2 then
                    love.graphics.setColor( COLORS.DB27 );
                    status = 'OUCH'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.4 then
                    love.graphics.setColor( COLORS.DB05 );
                    status = 'MEH'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.7 then
                    love.graphics.setColor( COLORS.DB08 );
                    status = 'OK'
                else
                    love.graphics.setColor( COLORS.DB10 );
                    status = 'FINE'
                end
                love.graphics.print( Translator.getText( bodyPart:getID() ), px + tw, py + th * counter )
                love.graphics.printf( status, px + tw, py + th * counter, ( SCREEN_WIDTH - 2 ) * tw, 'right' )

                if bodyPart:isBleeding() then
                    local str = string.format( 'Bleeding %1.2f', bodyPart:getBloodLoss() );
                    if bodyPart:getBloodLoss() / 1.0 < 0.2 then
                        love.graphics.setColor( COLORS.DB10 );
                    elseif bodyPart:getBloodLoss() / 1.0 < 0.4 then
                        love.graphics.setColor( COLORS.DB08 );
                    elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.7 then
                        love.graphics.setColor( COLORS.DB05 );
                    elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 1.0 then
                        love.graphics.setColor( COLORS.DB27 );
                    end
                    love.graphics.printf( str, px + tw, py + th * counter, ( SCREEN_WIDTH - 2 ) * tw, 'center' )
                end
            end
        end

        love.graphics.setColor( COLORS.DB20 );
        love.graphics.print( 'Type: ' .. Translator.getText( characterType ), px + tw, py + th )
        love.graphics.setColor( COLORS.RESET );
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'q' then
            ScreenManager.pop();
        end
    end

    function self:resize( sx, sy )
        px = math.floor( sx / tw ) * 0.5 - math.floor( SCREEN_WIDTH  * 0.5 )
        py = math.floor( sy / th ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 )
        px, py = px * tw, py * th
        Log.debug( string.format( "Adjust position for Health Screen -> %d (%d), %d (%d)", sx, px, sy, py ));
    end

    return self;
end

return HealthScreen;
