---
-- Allows the rotation of two-dimensional arrays by 90, 180 and 270 degrees.
-- Works with square and non square arrays.
-- @module ArrayRotation
--

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ArrayRotation = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Rotates a two dimensional array by 90°.
-- @tparam  table arr The array to rotate.
-- @treturn table     The rotated array.
--
local function rotate90( arr )
    local rotatedArray = {}
    for x = 1, #arr do
        for y = 1, #arr[x] do
            local r, c = #arr-(x-1), y
            rotatedArray[c] = rotatedArray[c] or {}
            rotatedArray[c][r] = arr[x][y]
        end
    end
    return rotatedArray
end

---
-- Rotates a two dimensional array by 180°.
-- @tparam  table arr The array to rotate.
-- @treturn table     The rotated array.
--
local function rotate180( arr )
    local rotatedArray = {}
    for x = 1, #arr do
        for y = 1, #arr[x] do
            local r, c = #arr-(x-1), #arr[x]-(y-1)
            rotatedArray[r] = rotatedArray[r] or {}
            rotatedArray[r][c] = arr[x][y]
        end
    end
    return rotatedArray
end

---
-- Rotates a two dimensional array by 270°.
-- @tparam  table arr The array to rotate.
-- @treturn table     The rotated array.
--
local function rotate270( arr )
    local rotatedArray = {}
    for x = 1, #arr do
        for y = 1, #arr[x] do
            local r, c = x, #arr[x]-(y-1)
            rotatedArray[c] = rotatedArray[c] or {}
            rotatedArray[c][r] = arr[x][y]
        end
    end
    return rotatedArray
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Rotates a two dimensional array.
-- @tparam  table  arr   The array to rotate.
-- @tparam  number steps The amount of rotation to apply (0=0°, 1=90°, 2=180°, 3=270°)
-- @treturn table        The rotated array.
--
function ArrayRotation.rotate( arr, steps )
    if steps == 0 then
        return arr
    elseif steps == 1 then
        return rotate90( arr )
    elseif steps == 2 then
        return rotate180( arr )
    elseif steps == 3 then
        return rotate270( arr )
    end
end

return ArrayRotation
