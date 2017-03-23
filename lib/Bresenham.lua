--==================================================================================
-- Copyright (C) 2015 - 2017 by Robert Machmer                                     =
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

local Bresenham = {
    _VERSION     = "2.1.0",
    _DESCRIPTION = "Bresenham's line algorithm written in Lua." ,
    _URL         = 'https://github.com/rm-code/bresenham/',
}

---
-- Maps a line from point (ox, oy) to point (ex, ey) onto a two dimensional
-- tile grid.
--
-- The callback function will be called for each tile the line passes on its
-- way from the origin to the target tile. The line algorithm can be stopped
-- early by making the callback return false.
--
-- The callback will receive parameters in the following order:
--      callback( ox, oy, counter, ... )
--
-- With ox and oy being the coordinates of the pixel the algorithm is currently
-- passing through, counter being the amount of passed pixels and ...
-- representing variable arguments passed through.
--
-- @tparam number ox The origin's x-coordinates.
-- @tparam number oy The origin's y-coordinates.
-- @tparam number ex The target's x-coordinates.
-- @tparam number ey The target's y-coordinates.
-- @tparam[opt] function callback
--                      A callback function being called for every tile the line passes.
--                      The line algorithm will stop if the callback returns false.
-- @tparam[opt] vararg ...
--                      Additional parameters which will be forwarded to the callback.
-- @treturn boolean     True if the target was reached, otherwise false.
-- @treturn number      The counter variable containing the number of passed pixels.
--
function Bresenham.line( ox, oy, ex, ey, callback, ... )
    local dx = math.abs( ex - ox )
    local dy = math.abs( ey - oy ) * -1

    local sx = ox < ex and 1 or -1
    local sy = oy < ey and 1 or -1
    local err = dx + dy

    local counter = 0
    while true do
        -- If a callback has been provided, it controls wether the line
        -- algorithm should proceed or not.
        if callback then
            local continue = callback( ox, oy, counter, ... )
            if not continue then
                return false, counter
            end
        end

        counter = counter + 1

        if ox == ex and oy == ey then
            return true, counter
        end

        local tmpErr = 2 * err
        if tmpErr > dy then
            err = err + dy
            ox = ox + sx
        end
        if tmpErr < dx then
            err = err + dx
            oy = oy + sy
        end
    end
end

return Bresenham
