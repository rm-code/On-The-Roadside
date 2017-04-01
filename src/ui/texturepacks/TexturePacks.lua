---
-- This class handles the loading and using of texture packs.
-- @module TexturePacks
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local TexturePack = require( 'src.ui.texturepacks.TexturePack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TexturePacks = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEXTURE_PACK_FOLDER     = 'res/texturepacks/'
local MOD_TEXTURE_PACK_FOLDER = 'mod/texturepacks/'
local INFO_FILE_NAME = 'info'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local texturePacks = {}
local current

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Checks if the loaded module provides all the necessary fields.
-- @tparam  table   module The loaded module to check.
-- @treturn boolean        True if the module is valid.
--
local function validate( module )
    if not module.name
    or not module.font
    or not module.tileset then
        return false
    end

    if not module.font.source
    or not module.font.glyphs
    or not module.tileset.source
    or not module.tileset.tiles then
        return false
    end

    if not module.font.glyphs.source
    or not module.font.glyphs.width
    or not module.font.glyphs.height
    or not module.tileset.tiles.width
    or not module.tileset.tiles.height then
        return false
    end

    return true
end

---
-- Loads a texture pack.
-- @tparam string   src The path to load the templates from.
-- @treturn boolean     True if the texture pack was loaded successfully.
-- @treturn TexturePack The loaded texture pack (only if successful).
--
local function load( src )
    local path = src .. INFO_FILE_NAME
    local module = require( path )
    if not module or not validate( module ) then
        return false
    end

    local tpack = TexturePack.new()
    tpack:init( src, module )

    return true, tpack
end

---
-- Loads texture packs from the provided path.
-- @tparam string sourceFolder The path to check for texture packs.
--
local function loadPacks( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        local path = sourceFolder .. item .. '/'
        if love.filesystem.isDirectory( path ) then
            local success, tpack = load( path )

            if success then
                local name = tpack:getName()
                -- Register new texture pack and make it the current one if
                -- there isn't a current one already.
                texturePacks[name] = tpack
                if not current then
                    current = name
                end

                count = count + 1
                Log.debug( string.format( '  %3d. %s', count, name ))
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function TexturePacks.load()
    Log.debug( "Load Default Texture Packs:" )
    loadPacks( TEXTURE_PACK_FOLDER )

    -- Creates the mods folder if it doesn't exist.
    if not love.filesystem.exists( MOD_TEXTURE_PACK_FOLDER ) then
        love.filesystem.createDirectory( MOD_TEXTURE_PACK_FOLDER )
    end

    Log.debug( "Load External Texture Packs:" )
    loadPacks( MOD_TEXTURE_PACK_FOLDER )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function TexturePacks.getTexturePacks()
    return texturePacks
end

function TexturePacks.getName()
    return texturePacks[current]:getName()
end

function TexturePacks.getFont()
    return texturePacks[current]:getFont()
end

function TexturePacks.getTileset()
    return texturePacks[current]:getTileset()
end

function TexturePacks.getTileDimensions()
    return texturePacks[current]:getTileset():getTileDimensions()
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function TexturePacks.setCurrent( ncurrent )
    current = ncurrent
end

return TexturePacks
