---
-- The boot loading screen takes care of loading the game's resources.
-- TODO use thread
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Log = require( 'src.util.Log' );
local Translator = require( 'src.util.Translator' );

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local BodyFactory = require( 'src.characters.body.BodyFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local BehaviorTreeFactory = require( 'src.characters.ai.behaviortree.BehaviorTreeFactory' );
local SoundManager = require( 'src.SoundManager' );
local MapLoader = require( 'src.map.MapLoader' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )

local CharacterFactory = require( 'src.characters.CharacterFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BootLoadingScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_LOCALE = 'en_EN';

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BootLoadingScreen.new()
    local self = Screen.new();

    function self:init()
        local startTime = love.timer.getTime();

        Translator.init( DEFAULT_LOCALE );

        TexturePacks.load()

        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        BodyFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        BehaviorTreeFactory.loadTemplates();
        SoundManager.loadResources();

        CharacterFactory.init()

        MapLoader.load()
        PrefabLoader.load()

        local endTime = love.timer.getTime();
        Log.debug( string.format( 'Loading game resources took %.3f seconds!', endTime - startTime ), 'BootLoadingScreen' );

        ScreenManager.switch( 'mainmenu' );
    end

    return self;
end

return BootLoadingScreen;
