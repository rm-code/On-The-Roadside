--==================================================================================
-- Copyright (C) 2017 by Robert Machmer                                            =
--                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy    =
-- of this software and associated documentation files (the "Software"), to deal   =
-- in the Software without restriction, including without limitation the rights    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       =
-- copies of the Software, and to permit persons to whom the Software is           =
-- furnished to do so, subject to the following conditions:                        =
--                                                                                 =
-- The above copyright notice and this permission notice shall be included in      =
-- all copies or substantial portions of the Software.                             =
--                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN       =
-- THE SOFTWARE.                                                                   =
--==================================================================================

local ArrayRotation= {
    _VERSION     = "1.0.0",
    _DESCRIPTION = "Rotation of arrays in 90° increments." ,
    _URL         = 'https://gist.github.com/rm-code/4118d4a97d8cde16952199d94b84ead0',
}

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
