-- ============================================================================== --
-- MIT License                                                                    --
--                                                                                --
-- Copyright (c) 2016 - 2018 Robert Machmer                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
-- ============================================================================== --

local TGFParser = {
    _VERSION     = '1.1.0',
    _DESCRIPTION = 'A parser for "Trivial Graph Format" (TGF) files written in Lua.',
    _URL         = 'https://github.com/rm-code/lua-tgf-parser/',
}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local NODE_REGEX = '(.+) (.+)'
local EDGE_REGEX = '(.+) (.+) (.+)'

-- ------------------------------------------------
-- Line iterator
-- ------------------------------------------------

local lines = love and love.filesystem.lines or io.lines

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Iterates over the file and stores the lines for nodes and edges in
-- different tables.
-- @tparam string path The path of the file to load.
-- @treturn table A sequence containing all node definitions.
-- @treturn table A sequence containing all edge definitions.
--
local function loadFile( path )
    local nodes = {}
    local edges = {}
    local target = nodes

    -- Change the target table once the '#' separator is reached.
    for line in lines( path ) do
        if line == '#' then
            target = edges
        else
            target[#target + 1] = line
        end
    end

    return nodes, edges
end

---
-- Tries to convert a string to a number.
--
local function convertNumber( n )
    return tonumber( n ) and tonumber( n ) or n
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Parses a .tgf file.
-- @tparam string path The path of the file to load.
-- @treturn table A table containing tables the nodes and edges of the graph.
--
function TGFParser.parse( path )
    local nodes, edges = loadFile( path )

    -- Set up the graph table.
    local graph = {}
    graph.nodes = {}
    graph.edges = {}

    -- Splits each line of the node definitions and stores them inside of the
    -- node table as nodes[id] = name.
    for _, line in ipairs( nodes ) do
        local id, label = string.match( line, NODE_REGEX )
        graph.nodes[#graph.nodes + 1] = { id = convertNumber( id ), label = label }
    end

    -- Splits each line of the edge definitions and stores them inside of the
    -- edge table as edges[i] = { from = nodeId1, to = nodeId2, name = edgeName }.
    for _, line in ipairs( edges ) do
        local from, to, label = string.match( line, EDGE_REGEX )
        graph.edges[#graph.edges + 1] = { from = convertNumber( from ), to = convertNumber( to ), label = label }
    end

    return graph
end

return TGFParser
