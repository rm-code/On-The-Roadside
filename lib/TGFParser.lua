-- ============================================================================== --
-- MIT License                                                                    --
--                                                                                --
-- Copyright (c) 2016 Robert Machmer                                              --
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
    _VERSION     = '1.0.0',
    _DESCRIPTION = 'A parser for "Trivial Graph Format" (TGF) files written in Lua.',
    _URL         = 'https://github.com/rm-code/lua-tgf-parser/',
};

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Iterates over the file and separates the lines for nodes and edges into
-- different tables.
-- @param path (string)   The path of the file to load.
-- @return     (sequence) A sequence containing all node definitions.
-- @return     (sequence) A sequence containing all edge definitions.
--
local function loadFile( path )
    local nodes = {};
    local edges = {};
    local target = nodes;

    -- Change the target table once the '#' separator is reached.
    for line in io.lines( path ) do
        if line == '#' then
            target = edges;
        else
            target[#target + 1] = line;
        end
    end

    return nodes, edges;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Parses a .tgf file.
-- @param path (string) The path of the file to load.
-- @return     (table)  The table containing the nodes and edges of the graph.
--
function TGFParser.parse( path )
    local nodes, edges = loadFile( path );

    -- Set up the graph table.
    local graph = {};
    graph.nodes = {};
    graph.edges = {};

    -- Splits each line of the node definitions and stores them inside of the
    -- node table as nodes[id] = name.
    for _, line in ipairs( nodes ) do
        local id, name = string.match( line, '(%d+) (.+)' );
        id = tonumber( id );
        graph.nodes[id] = name;
    end

    -- Splits each line of the edge definitions and stores them inside of the
    -- edge table as edges[i] = { from = nodeId1, to = nodeId2, name = edgeName }.
    for _, line in ipairs( edges ) do
        local f, t, e = string.match( line, '(%d+) (%d+) (%d+)' );
        f, t = tonumber( f ), tonumber( t );
        graph.edges[#graph.edges + 1] = { from = f, to = t, name = e };
    end

    return graph;
end

return TGFParser;
