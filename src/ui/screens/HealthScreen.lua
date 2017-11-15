local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Translator = require( 'src.util.Translator' );
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HealthScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 30
local UI_GRID_HEIGHT = 16

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function HealthScreen.new()
    local self = Screen.new();

    local character;
    local characterType;

    local background
    local outlines
    local x, y
    local tw, th

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Generates the outlines for this screen.
    --
    local function generateOutlines()
        outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        -- Horizontal borders.
        for ox = 0, UI_GRID_WIDTH-1 do
            outlines:add( ox, 0                ) -- Top
            outlines:add( ox, 2                ) -- Header
            outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
        end

        -- Vertical outlines.
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 0,               oy ) -- Left
            outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
        end

        outlines:refresh()
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ncharacter )
        tw, th = TexturePacks.getTileDimensions()
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        character = ncharacter;
        characterType = character:getBody():getID();

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()
    end

    function self:draw()
        background:draw()
        outlines:draw()

        local counter = 3;
        for _, bodyPart in pairs( character:getBody():getBodyParts() ) do
            if bodyPart:isEntryNode() then
                counter = counter + 1;
                local status;
                if bodyPart:isDestroyed() then
                    TexturePacks.setColor( 'ui_health_destroyed_limb' )
                    status = 'DED'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.2 then
                    TexturePacks.setColor( 'ui_health_badly_damaged_limb' )
                    status = 'OUCH'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.4 then
                    TexturePacks.setColor( 'ui_health_damaged_limb' )
                    status = 'MEH'
                elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.7 then
                    TexturePacks.setColor( 'ui_health_ok_limb' )
                    status = 'OK'
                else
                    TexturePacks.setColor( 'ui_health_fine_limb' )
                    status = 'FINE'
                end
                love.graphics.print( Translator.getText( bodyPart:getID() ), (x+1) * tw, (y+counter) * th )
                love.graphics.printf( status, (x+1) * tw, (y+counter) * th, ( UI_GRID_WIDTH - 2 ) * tw, 'right' )

                if bodyPart:isBleeding() then
                    local str = string.format( 'Bleeding %1.2f', bodyPart:getBloodLoss() );
                    if bodyPart:getBloodLoss() / 1.0 < 0.2 then
                        TexturePacks.setColor( 'ui_health_bleeding_fine' )
                    elseif bodyPart:getBloodLoss() / 1.0 < 0.4 then
                        TexturePacks.setColor( 'ui_health_bleeding_ok' )
                    elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 0.7 then
                        TexturePacks.setColor( 'ui_health_bleeding' )
                    elseif bodyPart:getHealth() / bodyPart:getMaxHealth() < 1.0 then
                        TexturePacks.setColor( 'ui_health_bleeding_bad' )
                    end
                    love.graphics.printf( str, (x+1) * tw, (y+counter) * th, ( UI_GRID_WIDTH - 2 ) * tw, 'center' )
                end
            end
        end

        TexturePacks.setColor( 'ui_text' )

        -- Draw character type.
        local type = Translator.getText( 'ui_character_type' ) .. Translator.getText( characterType )
        love.graphics.print( type, (x+1) * tw, (y+1) * th )

        -- Draw character name.
        if character:getName() then
            local name = Translator.getText( 'ui_character_name' ) .. character:getName()
            love.graphics.print( name, (x+2) * tw + TexturePacks.getFont():measureWidth( type ), (y+1) * th )
        end

        TexturePacks.resetColor()
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'h' then
            ScreenManager.pop();
        end
    end

    return self;
end

return HealthScreen;
