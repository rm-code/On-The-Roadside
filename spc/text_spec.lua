describe( 'Text file spec', function()
    local FILE_PATH = 'res/text/%s';
    local MODULE_PATH = 'res.text.%s.';

    ---
    -- Returns the names of all files located in a certain directory.
    -- @param dir (string) The path to the directory to load from.
    -- @return    (table)  A sequence containing all file names.
    --
    local function getDirectoryItems( dir )
        local i, t = 0, {};
        local pfile = io.popen( 'ls "'..dir..'"' );
        for filename in pfile:lines() do
            i = i + 1;
            t[i] = filename:match( '^(.+)%..+$' );
        end
        pfile:close();
        return t;
    end

    ---
    -- Requires all modules based on their file names and the specified path.
    -- @param t    (table)  A sequence containing all file names.
    -- @param path (string) The path from which the modules should be required.
    -- @return     (table)  A sequence containing all required modules.
    --
    local function loadFiles( t, path )
        local files = {};
        for i, filename in ipairs( t ) do
            files[i] = require( path .. filename );
        end
        return files;
    end

    describe( 'for english locale', function()
        local LOCALE = 'en_EN';

        local fileNames = getDirectoryItems( string.format( FILE_PATH, LOCALE ));
        local files = loadFiles( fileNames, string.format( MODULE_PATH, LOCALE ));

        it( 'makes sure all files have the correct locale', function()
            for _, file in ipairs( files ) do
                assert.is_true( file.identifier == LOCALE );
            end
        end)

        it( 'makes sure all text lines have a unique key', function()
            local keys = {};
            for _, file in ipairs( files ) do
                for key, _ in pairs( file.strings ) do
                    assert.is_not_true( keys[key], key );
                    keys[key] = true;
                end
            end
        end)
    end)

    describe( 'for german locale', function()
        local LOCALE = 'de_DE';

        local fileNames = getDirectoryItems( string.format( FILE_PATH, LOCALE ));
        local files = loadFiles( fileNames, string.format( MODULE_PATH, LOCALE ));

        it( 'makes sure all files have the correct locale', function()
            for _, file in ipairs( files ) do
                assert.is_true( file.identifier == LOCALE );
            end
        end)

        it( 'makes sure all text lines have a unique key', function()
            local keys = {};
            for _, file in ipairs( files ) do
                for key, _ in pairs( file.strings ) do
                    assert.is_not_true( keys[key], key );
                    keys[key] = true;
                end
            end
        end)
    end)
end)
