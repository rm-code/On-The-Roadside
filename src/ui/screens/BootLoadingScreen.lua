---
-- The boot loading screen takes care of loading the game's resources.
-- TODO use thread
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local Log = require( 'src.util.Log' )
local Translator = require( 'src.util.Translator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local ItemFactory = require( 'src.items.ItemFactory' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local BodyFactory = require( 'src.characters.body.BodyFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local BehaviorTreeFactory = require( 'src.characters.ai.behaviortree.BehaviorTreeFactory' )
local SoundManager = require( 'src.SoundManager' )
local ProceduralMapGenerator = require( 'src.map.procedural.ProceduralMapGenerator' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local CharacterFactory = require( 'src.characters.CharacterFactory' )
local Settings = require( 'src.Settings' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BootLoadingScreen = Screen:subclass( 'BootLoadingScreen' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BootLoadingScreen:initialize()
    local startTime = love.timer.getTime()

    TexturePacks.load()
    SoundManager.load()

    ItemFactory.loadTemplates()
    TileFactory.loadTemplates()
    BodyFactory.loadTemplates()
    WorldObjectFactory.loadTemplates()
    BehaviorTreeFactory.loadTemplates()

    CharacterFactory.init()

    ProceduralMapGenerator.load()
    PrefabLoader.load()

    Settings.load()

    Translator.init( Settings.getLocale() )
    TexturePacks.setCurrent( Settings.getTexturepack() )
    love.window.setFullscreen( Settings.getFullscreen() )

    local endTime = love.timer.getTime()
    Log.debug( string.format( 'Loading game resources took %.3f seconds!', endTime - startTime ), 'BootLoadingScreen' )

    ScreenManager.switch( 'mainmenu' )
end

return BootLoadingScreen
