local VectorMath = {};

---
-- Rotates the target position by the given angle.
-- @param px     (number)
-- @param py     (number)
-- @param tx     (number)
-- @param ty     (number)
-- @param angle  (number)
-- @param factor (number) Change the vector's magnitude.
-- @return       (number) The new target along the x-axis.
-- @return       (number) The new target along the y-axis.
--
function VectorMath.rotate( px, py, tx, ty, angle, factor )
    local vx, vy = tx - px, ty - py;

    factor = factor or 1;
    vx = vx * factor;
    vy = vy * factor;

    -- Transform angle from degrees to radians.
    angle = math.rad( angle );

    local nx = vx * math.cos( angle ) - vy * math.sin( angle );
    local ny = vx * math.sin( angle ) + vy * math.cos( angle );

    return px + nx, py + ny;
end

return VectorMath;
