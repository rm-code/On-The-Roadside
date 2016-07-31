local Pulser = {};

function Pulser.new( nspeed, noffset, nrange )
    local self = {};

    local speed = nspeed or 1;
    local offset = noffset or 1;
    local range = nrange or 1;
    local timer = 0;
    local value;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Returns gradually changing values between 0 and 1 which can be used to
    -- make elements slowly pulsate.
    -- @param dt (number) The time since the last update in seconds.
    --
    function self:update( dt )
        timer = timer + dt * speed;
        local sin = math.sin( timer );
        value = math.abs( sin ) * range + offset;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the pulse value.
    -- @return (number) A value between 0 and 1.
    --
    function self:getPulse()
        return value;
    end

    return self;
end

return Pulser;
