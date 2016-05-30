local Item = require( 'src.items.Item' );
local FIRING_MODES = require( 'src.constants.FiringModes' );

local Weapon = {};

function Weapon.new( template )
    local self = Item.new( template.name ):addInstance( 'Weapon' );

    local damage = template.damage;
    local range  = template.range;
    local mode = FIRING_MODES.SINGLE;

    function self:getAccuracy()
        return template.mode[mode].accuracy;
    end

    function self:getDamage()
        return damage;
    end

    function self:getFiringMode()
        return mode;
    end

    function self:getRange()
        return range;
    end

    function self:getAttackCost()
        return template.mode[mode].cost;
    end

    function self:getShots()
        return template.mode[mode].shots;
    end

    function self:selectNextFiringMode()
        if mode == FIRING_MODES.SINGLE then
            mode = FIRING_MODES.BURST;
        elseif mode == FIRING_MODES.BURST then
            mode = FIRING_MODES.AUTO;
        elseif mode == FIRING_MODES.AUTO then
            mode = FIRING_MODES.SINGLE;
        end
    end

    function self:selectPrevFiringMode()
        if mode == FIRING_MODES.SINGLE then
            mode = FIRING_MODES.AUTO;
        elseif mode == FIRING_MODES.BURST then
            mode = FIRING_MODES.SINGLE;
        elseif mode == FIRING_MODES.AUTO then
            mode = FIRING_MODES.BURST;
        end
    end

    return self;
end

return Weapon;
